//
//  CameraEngine.swift
//  Camera
//
//  Manages AVCaptureSession lifecycle for camera preview and capture.
//  All session operations are performed on a dedicated background queue.
//

import AVFoundation
import Combine
import UIKit

/// Represents the current state of the CameraEngine
enum CameraEngineState: Equatable, Sendable {
  case idle
  case starting
  case running
  case interrupted
  case error(String)

  static func == (lhs: CameraEngineState, rhs: CameraEngineState) -> Bool {
    switch (lhs, rhs) {
    case (.idle, .idle), (.starting, .starting), (.running, .running), (.interrupted, .interrupted):
      return true
    case (.error(let l), .error(let r)):
      return l == r
    default:
      return false
    }
  }
}

/// Protocol for AVCaptureSession to enable testing
protocol CaptureSessionProtocol: AnyObject {
  var isRunning: Bool { get }
  var sessionPreset: AVCaptureSession.Preset { get set }
  func beginConfiguration()
  func commitConfiguration()
  func startRunning()
  func stopRunning()
  func canAddInput(_ input: AVCaptureInput) -> Bool
  func addInput(_ input: AVCaptureInput)
  func canAddOutput(_ output: AVCaptureOutput) -> Bool
  func addOutput(_ output: AVCaptureOutput)
}

/// Make AVCaptureSession conform to CaptureSessionProtocol
extension AVCaptureSession: CaptureSessionProtocol {}

/// Protocol for AVCaptureDevice to enable testing
protocol CaptureDeviceProtocol: AnyObject, Sendable {
  var isFocusPointOfInterestSupported: Bool { get }
  var focusPointOfInterest: CGPoint { get set }
  var focusMode: AVCaptureDevice.FocusMode { get set }

  var isExposurePointOfInterestSupported: Bool { get }
  var exposurePointOfInterest: CGPoint { get set }
  var exposureMode: AVCaptureDevice.ExposureMode { get set }

  var isSubjectAreaChangeMonitoringEnabled: Bool { get set }

  var whiteBalanceMode: AVCaptureDevice.WhiteBalanceMode { get set }

  // ISO/Exposure properties for manual control
  var activeFormat: AVCaptureDevice.Format { get }
  var iso: Float { get }
  var exposureDuration: CMTime { get }
  var lensAperture: Float { get }

  // Focus/lens position properties for manual focus control
  var lensPosition: Float { get }

  func isFocusModeSupported(_ focusMode: AVCaptureDevice.FocusMode) -> Bool
  func isExposureModeSupported(_ exposureMode: AVCaptureDevice.ExposureMode) -> Bool
  func isWhiteBalanceModeSupported(_ whiteBalanceMode: AVCaptureDevice.WhiteBalanceMode) -> Bool

  func lockForConfiguration() throws
  func unlockForConfiguration()

  // Manual exposure control
  func setExposureModeCustom(
    duration: CMTime,
    iso: Float,
    completionHandler handler: ((CMTime) -> Void)?
  )

  // Manual focus control
  func setFocusModeLocked(lensPosition: Float, completionHandler handler: ((CMTime) -> Void)?)

  // Manual white balance control
  var maxWhiteBalanceGain: Float { get }
  func deviceWhiteBalanceGains(
    for temperatureAndTint: AVCaptureDevice.WhiteBalanceTemperatureAndTintValues
  ) -> AVCaptureDevice.WhiteBalanceGains
  func setWhiteBalanceModeLocked(
    with gains: AVCaptureDevice.WhiteBalanceGains,
    completionHandler handler: ((CMTime) -> Void)?
  )

  // Zoom control
  var videoZoomFactor: CGFloat { get set }
  var minAvailableVideoZoomFactor: CGFloat { get }
  var maxAvailableVideoZoomFactor: CGFloat { get }
  var virtualDeviceSwitchOverVideoZoomFactors: [NSNumber] { get }

  func ramp(toVideoZoomFactor factor: CGFloat, withRate rate: Float)
  func cancelVideoZoomRamp()
}

/// Make AVCaptureDevice conform to CaptureDeviceProtocol
extension AVCaptureDevice: CaptureDeviceProtocol {}

/// Protocol for providing capture devices to enable testing
protocol CaptureDeviceProviding: Sendable {
  func defaultDevice(
    for deviceType: AVCaptureDevice.DeviceType,
    mediaType: AVMediaType,
    position: AVCaptureDevice.Position
  ) -> (any CaptureDeviceProtocol)?
}

/// Production implementation using AVCaptureDevice.DiscoverySession
final class ProductionCaptureDeviceProvider: CaptureDeviceProviding, Sendable {
  func defaultDevice(
    for deviceType: AVCaptureDevice.DeviceType,
    mediaType: AVMediaType,
    position: AVCaptureDevice.Position
  ) -> (any CaptureDeviceProtocol)? {
    let discoverySession = AVCaptureDevice.DiscoverySession(
      deviceTypes: [deviceType],
      mediaType: mediaType,
      position: position
    )
    return discoverySession.devices.first
  }
}

/// Manages AVFoundation capture session lifecycle
/// All session operations execute on a dedicated serial queue
final class CameraEngine: NSObject, @unchecked Sendable {

  // MARK: - Shared Instance for Early Initialization

  /// Shared instance for pre-warming during app launch
  static let shared = CameraEngine()

  // MARK: - Properties

  /// Current state of the camera engine
  @Published private(set) var state: CameraEngineState = .idle

  /// Current ISO value (updated on main thread for UI binding)
  @Published private(set) var currentISO: Float = 100.0

  /// Minimum ISO supported by current device format
  @Published private(set) var minISO: Float = 32.0

  /// Maximum ISO supported by current device format
  @Published private(set) var maxISO: Float = 3200.0

  /// Current exposure duration (shutter speed) for UI binding
  @Published private(set) var currentExposureDuration: CMTime = CMTime(value: 1, timescale: 60)

  /// Minimum exposure duration supported by current device format (fastest shutter)
  @Published private(set) var minExposureDuration: CMTime = CMTime(value: 1, timescale: 8000)

  /// Maximum exposure duration supported by current device format (slowest shutter)
  @Published private(set) var maxExposureDuration: CMTime = CMTime(value: 1, timescale: 4)

  /// Current aperture (f-stop) for UI binding
  @Published private(set) var currentAperture: Float = 1.8

  /// Current lens position for manual focus (0.0 = near/macro, 1.0 = infinity)
  @Published private(set) var currentLensPosition: Float = 0.5

  /// Whether manual focus is currently active
  @Published private(set) var isUsingManualFocus: Bool = false

  /// Current white balance temperature in Kelvin (2000K - 10000K range)
  @Published private(set) var currentTemperatureKelvin: Float = 5500.0

  /// Whether manual white balance is currently active
  @Published private(set) var isUsingManualWhiteBalance: Bool = false

  /// Current zoom factor (1.0 = wide/default)
  @Published private(set) var currentZoomFactor: CGFloat = 1.0

  /// Available lens zoom factors (e.g. [0.5, 1.0, 3.0])
  @Published private(set) var availableLensFactors: [CGFloat] = [1.0]

  /// Whether the session is currently running
  var isSessionRunning: Bool {
    lock.withLock { captureSession.isRunning }
  }

  /// The underlying capture session (exposed for preview layer)
  /// Returns the real AVCaptureSession - only use with production sessions
  var session: AVCaptureSession {
    guard let realSession = captureSession as? AVCaptureSession else {
      // For mocks in tests, return a new session (won't be used for actual preview)
      return AVCaptureSession()
    }
    return realSession
  }

  private let captureSession: any CaptureSessionProtocol
  private let deviceProvider: any CaptureDeviceProviding
  private let sessionQueue: DispatchQueue
  private let lock = NSLock()
  private var isConfigured = false

  // Keep regular reference for configuration
  private var activeVideoDevice: (any CaptureDeviceProtocol)?

  private let photoOutput = AVCapturePhotoOutput()

  /// References to in-progress capture processors to keep them alive
  private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()

  // MARK: - Constants

  private let zoomRampRate: Float = 5.0

  // MARK: - KVO Context
  private var exposureContext = 0

  // MARK: - Notification Observers

  private var interruptionObserver: NSObjectProtocol?
  private var interruptionEndedObserver: NSObjectProtocol?
  private var runtimeErrorObserver: NSObjectProtocol?
  private var subjectAreaChangeObserver: NSObjectProtocol?

  // MARK: - Initialization

  init(
    captureSession: any CaptureSessionProtocol = AVCaptureSession(),
    deviceProvider: any CaptureDeviceProviding = ProductionCaptureDeviceProvider(),
    sessionQueue: DispatchQueue = DispatchQueue(label: "com.camera.sessionQueue")
  ) {
    self.captureSession = captureSession
    self.deviceProvider = deviceProvider
    self.sessionQueue = sessionQueue
    setupNotificationObservers()
  }

  deinit {
    removeNotificationObservers()
    stopObservingExposureValues()
  }

  // MARK: - Public Methods

  /// Pre-warms the capture session by configuring it without starting
  /// Call this early in app launch to reduce time to first frame
  func preWarm() {
    sessionQueue.async { [weak self] in
      guard let self = self, !self.isConfigured else { return }
      self.configureSession()
    }
  }

  /// Starts the capture session on a background queue
  func startSession() async {
    await withCheckedContinuation { continuation in
      sessionQueue.async { [weak self] in
        guard let self = self else {
          continuation.resume()
          return
        }

        if !self.isConfigured {
          self.configureSession()
        }

        if !self.captureSession.isRunning {
          self.updateState(.starting)
          self.captureSession.startRunning()
          self.updateState(.running)
        }
        continuation.resume()
      }
    }
  }

  /// Stops the capture session on a background queue
  func stopSession() async {
    await withCheckedContinuation { continuation in
      sessionQueue.async { [weak self] in
        guard let self = self else {
          continuation.resume()
          return
        }

        if self.captureSession.isRunning {
          self.captureSession.stopRunning()
          self.updateState(.idle)
        }
        continuation.resume()
      }
    }
  }

  /// Focuses the camera at a specific point
  /// - Parameter point: The point of interest (0,0 is top-left, 1,1 is bottom-right)
  func focus(at point: CGPoint) {
    sessionQueue.async { [weak self] in
      guard let self = self, let device = self.activeVideoDevice else { return }

      do {
        try device.lockForConfiguration()

        // Focus
        if device.isFocusPointOfInterestSupported {
          device.focusPointOfInterest = point
          device.focusMode = .autoFocus
        }

        // Exposure
        if device.isExposurePointOfInterestSupported {
          device.exposurePointOfInterest = point
          device.exposureMode = .continuousAutoExposure
        }

        // Subject Monitoring
        device.isSubjectAreaChangeMonitoringEnabled = true

        device.unlockForConfiguration()
      } catch {
        // Log critical error
        print(
          "[CameraEngine] 🚨 Failed to lock configuration for focus: \(error.localizedDescription)")
      }
    }
  }

  /// Captures a photo using the configured settings
  /// - Parameter completion: Called with the captured data or an error
  func capturePhoto(completion: @escaping (Result<Data, Error>) -> Void) {
    sessionQueue.async { [weak self] in
      guard let self = self else { return }

      // Update orientation
      if let connection = self.photoOutput.connection(with: .video),
        connection.isVideoOrientationSupported
      {
        connection.videoOrientation = self.currentVideoOrientation
      }

      var photoSettings = AVCapturePhotoSettings()

      // Prefer HEIC if available
      if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
        photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
      }

      let uniqueID = photoSettings.uniqueID

      let processor = PhotoCaptureProcessor { [weak self] result in
        completion(result)

        // Remove self from delegates to release memory
        self?.sessionQueue.async {
          self?.inProgressPhotoCaptureDelegates[uniqueID] = nil
        }
      }

      self.inProgressPhotoCaptureDelegates[uniqueID] = processor
      self.photoOutput.capturePhoto(with: photoSettings, delegate: processor)
    }
  }

  private var currentVideoOrientation: AVCaptureVideoOrientation {
    switch UIDevice.current.orientation {
    case .portrait: return .portrait
    case .portraitUpsideDown: return .portraitUpsideDown
    case .landscapeLeft: return .landscapeRight  // Camera orientation is mirrored? No, usually device left = camera right
    case .landscapeRight: return .landscapeLeft
    default: return .portrait
    }
  }

  // MARK: - Session Configuration

  private func configureSession() {
    captureSession.beginConfiguration()
    captureSession.sessionPreset = .photo

    // Add video input
    // Prioritize triple camera, then dual wide, then wide
    let deviceTypes: [AVCaptureDevice.DeviceType] = [
      .builtInTripleCamera,
      .builtInDualWideCamera,
      .builtInWideAngleCamera,
    ]

    var selectedDevice: (any CaptureDeviceProtocol)?

    for type in deviceTypes {
      if let device = deviceProvider.defaultDevice(
        for: type,
        mediaType: .video,
        position: .back
      ) {
        selectedDevice = device
        break
      }
    }

    guard let videoDevice = selectedDevice else {
      captureSession.commitConfiguration()
      updateState(.error("No camera device available"))
      return
    }

    // Store device for later use (focus/exposure)
    activeVideoDevice = videoDevice

    do {
      // We need to cast back to AVCaptureDevice to create input, or wrap input creation too.
      // Since AVCaptureDeviceInput takes AVCaptureDevice, and we can't easily mock that init without wrapping,
      // For now, checking if it is a real device if we are in production.
      // For testing, we might skip adding input or mock the session's addInput behavior differently.

      if let realDevice = videoDevice as? AVCaptureDevice {
        let videoInput = try AVCaptureDeviceInput(device: realDevice)
        if captureSession.canAddInput(videoInput) {
          captureSession.addInput(videoInput)
        } else {
          captureSession.commitConfiguration()
          updateState(.error("Could not add video input"))
          return
        }
      } else {
        // Handle mock device case if needed, or rely on mock session to ignore input check validation
        // for now just proceed as if input was added if it's a mock
      }

      // Add photo output
      if captureSession.canAddOutput(photoOutput) {
        captureSession.addOutput(photoOutput)
        photoOutput.isHighResolutionCaptureEnabled = true
      } else {
        captureSession.commitConfiguration()
        updateState(.error("Could not add photo output"))
        return
      }

    } catch {
      captureSession.commitConfiguration()
      updateState(.error("Failed to create video input: \(error.localizedDescription)"))
      return
    }

    captureSession.commitConfiguration()
    isConfigured = true

    // Initialize ISO and exposure duration bounds from active device format
    updateISOBounds()
    updateExposureDurationBounds()

    updateZoomCapabilities()

    // Start observing exposure values
    startObservingExposureValues()
  }

  // MARK: - State Management

  private func updateState(_ newState: CameraEngineState) {
    DispatchQueue.main.async {
      self.state = newState
    }
  }

  // MARK: - Notification Handling

  private func setupNotificationObservers() {
    // Only observe notifications for our specific session (if it's a real AVCaptureSession)
    let sessionObject = captureSession as? AVCaptureSession

    interruptionObserver = NotificationCenter.default.addObserver(
      forName: AVCaptureSession.wasInterruptedNotification,
      object: sessionObject,
      queue: .main
    ) { [weak self] notification in
      self?.handleSessionInterruption(notification)
    }

    interruptionEndedObserver = NotificationCenter.default.addObserver(
      forName: AVCaptureSession.interruptionEndedNotification,
      object: sessionObject,
      queue: .main
    ) { [weak self] _ in
      self?.handleSessionInterruptionEnded()
    }

    runtimeErrorObserver = NotificationCenter.default.addObserver(
      forName: AVCaptureSession.runtimeErrorNotification,
      object: sessionObject,
      queue: .main
    ) { [weak self] notification in
      self?.handleRuntimeError(notification)
    }

    // Observe Subject Area Changes (e.g. user moved camera significantly)
    subjectAreaChangeObserver = NotificationCenter.default.addObserver(
      forName: AVCaptureDevice.subjectAreaDidChangeNotification,
      object: nil,  // Observe any device change, or filter if we had the precise AVCaptureDevice reference that conforms to NSObject
      queue: .main
    ) { [weak self] notification in
      self?.handleSubjectAreaDidChange(notification)
    }
  }

  private func removeNotificationObservers() {
    if let observer = interruptionObserver {
      NotificationCenter.default.removeObserver(observer)
    }
    if let observer = interruptionEndedObserver {
      NotificationCenter.default.removeObserver(observer)
    }
    if let observer = runtimeErrorObserver {
      NotificationCenter.default.removeObserver(observer)
    }
    if let observer = subjectAreaChangeObserver {
      NotificationCenter.default.removeObserver(observer)
    }
  }

  private func handleSessionInterruption(_ notification: Notification) {
    updateState(.interrupted)
  }

  private func handleSessionInterruptionEnded() {
    sessionQueue.async { [weak self] in
      guard let self = self else { return }
      if !self.captureSession.isRunning {
        self.captureSession.startRunning()
        self.updateState(.running)
      }
    }
  }

  private func handleSubjectAreaDidChange(_ notification: Notification) {
    sessionQueue.async { [weak self] in
      guard let self = self, let device = self.activeVideoDevice else { return }

      // Ideally check if notification.object is our device, but `activeVideoDevice` is protocol.
      // For now, simple approach: just reset if we have an active device.

      do {
        try device.lockForConfiguration()

        // Reset to continuous auto focus/exposure (center weighted usually default)
        device.focusMode = .continuousAutoFocus
        device.exposureMode = .continuousAutoExposure
        device.isSubjectAreaChangeMonitoringEnabled = false

        device.unlockForConfiguration()
      } catch {
        print("[CameraEngine] 🚨 Failed to reset subject area focus: \(error.localizedDescription)")
      }
    }
  }

  private func handleRuntimeError(_ notification: Notification) {
    guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else {
      return
    }
    updateState(.error(error.localizedDescription))

    // Attempt to recover from media services reset
    sessionQueue.async { [weak self] in
      guard let self = self else { return }
      if !self.captureSession.isRunning {
        self.captureSession.startRunning()
        self.updateState(.running)
      }
    }
  }

  /// Resets camera configuration to automatic modes
  func resetToAuto() {
    sessionQueue.async { [weak self] in
      guard let self = self, let device = self.activeVideoDevice else { return }

      do {
        try device.lockForConfiguration()

        if device.isFocusModeSupported(.continuousAutoFocus) {
          device.focusMode = .continuousAutoFocus
        }

        if device.isExposureModeSupported(.continuousAutoExposure) {
          device.exposureMode = .continuousAutoExposure
        }

        if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
          device.whiteBalanceMode = .continuousAutoWhiteBalance
        }

        // Reset subject area monitoring
        device.isSubjectAreaChangeMonitoringEnabled = false

        device.unlockForConfiguration()

        // Update ISO state to reflect auto mode current values
        self.updateISOState()
      } catch {
        print("[CameraEngine] 🚨 Failed to reset to auto: \(error.localizedDescription)")
      }
    }
  }

  // MARK: - ISO Control

  /// Sets manual ISO value while preserving current exposure duration
  /// - Parameter iso: The ISO value to set (will be clamped to device limits)
  func setISO(_ iso: Float) {
    sessionQueue.async { [weak self] in
      guard let self = self, let device = self.activeVideoDevice else { return }

      let format = device.activeFormat
      let clampedISO = max(format.minISO, min(iso, format.maxISO))

      // Preserve current exposure duration when changing ISO
      let currentDuration = device.exposureDuration

      do {
        try device.lockForConfiguration()
        device.setExposureModeCustom(
          duration: currentDuration, iso: clampedISO, completionHandler: nil)
        device.unlockForConfiguration()

        // Update published state on main thread
        DispatchQueue.main.async {
          self.currentISO = clampedISO
        }
      } catch {
        print("[CameraEngine] 🚨 Failed to set ISO: \(error.localizedDescription)")
      }
    }
  }

  /// Updates ISO bounds based on active device format
  private func updateISOBounds() {
    guard let device = activeVideoDevice else { return }

    let format = device.activeFormat
    DispatchQueue.main.async {
      self.minISO = format.minISO
      self.maxISO = format.maxISO
    }
  }

  /// Updates current ISO state from device
  private func updateISOState() {
    guard let device = activeVideoDevice else { return }

    let currentDeviceISO = device.iso
    DispatchQueue.main.async {
      self.currentISO = currentDeviceISO
    }
  }

  // MARK: - Shutter Speed Control

  /// Sets manual shutter speed (exposure duration) while preserving current ISO
  /// - Parameter duration: The exposure duration to set (will be clamped to device limits)
  func setShutterSpeed(_ duration: CMTime) {
    sessionQueue.async { [weak self] in
      guard let self = self, let device = self.activeVideoDevice else { return }

      let format = device.activeFormat
      let minDuration = format.minExposureDuration
      let maxDuration = format.maxExposureDuration

      // Clamp duration to device limits
      let clampedSeconds = max(minDuration.seconds, min(duration.seconds, maxDuration.seconds))
      let clampedDuration = CMTime(seconds: clampedSeconds, preferredTimescale: duration.timescale)

      // Preserve current ISO when changing shutter speed
      let currentISO = device.iso

      do {
        try device.lockForConfiguration()
        device.setExposureModeCustom(
          duration: clampedDuration, iso: currentISO, completionHandler: nil)
        device.unlockForConfiguration()

        // Update published state on main thread
        DispatchQueue.main.async {
          self.currentExposureDuration = clampedDuration
        }
      } catch {
        print("[CameraEngine] 🚨 Failed to set shutter speed: \(error.localizedDescription)")
      }
    }
  }

  /// Updates exposure duration bounds based on active device format
  private func updateExposureDurationBounds() {
    guard let device = activeVideoDevice else { return }

    let format = device.activeFormat
    DispatchQueue.main.async {
      self.minExposureDuration = format.minExposureDuration
      self.maxExposureDuration = format.maxExposureDuration
    }
  }

  /// Updates current exposure duration state from device
  private func updateExposureDurationState() {
    guard let device = activeVideoDevice else { return }

    let currentDuration = device.exposureDuration
    DispatchQueue.main.async {
      self.currentExposureDuration = currentDuration
    }
  }

  // MARK: - Focus Control

  /// Sets manual focus to a specific lens position
  /// - Parameter lensPosition: The lens position (0.0 = near/macro, 1.0 = infinity)
  func setFocusLensPosition(_ lensPosition: Float) {
    sessionQueue.async { [weak self] in
      guard let self = self, let device = self.activeVideoDevice else { return }

      // Clamp lens position to valid range
      let clampedPosition = max(0.0, min(lensPosition, 1.0))

      do {
        try device.lockForConfiguration()
        device.setFocusModeLocked(lensPosition: clampedPosition, completionHandler: nil)
        device.unlockForConfiguration()

        // Update published state on main thread
        DispatchQueue.main.async {
          self.currentLensPosition = clampedPosition
          self.isUsingManualFocus = true
        }
      } catch {
        print("[CameraEngine] 🚨 Failed to set focus lens position: \(error.localizedDescription)")
      }
    }
  }

  /// Resets focus to continuous auto-focus mode
  func setAutoFocus() {
    sessionQueue.async { [weak self] in
      guard let self = self, let device = self.activeVideoDevice else { return }

      do {
        try device.lockForConfiguration()

        if device.isFocusModeSupported(.continuousAutoFocus) {
          device.focusMode = .continuousAutoFocus
        }

        device.unlockForConfiguration()

        // Capture lens position before leaving session queue (H1 fix)
        let capturedLensPosition = device.lensPosition

        // Update published state on main thread
        DispatchQueue.main.async {
          self.isUsingManualFocus = false
          self.currentLensPosition = capturedLensPosition
        }
      } catch {
        print("[CameraEngine] 🚨 Failed to set auto focus: \(error.localizedDescription)")
      }
    }
  }

  // MARK: - White Balance Control

  /// Sets manual white balance to a specific color temperature in Kelvin
  /// - Parameter kelvin: The color temperature (will be clamped to 2000K-10000K range)
  func setWhiteBalanceTemperature(_ kelvin: Float) {
    sessionQueue.async { [weak self] in
      guard let self = self, let device = self.activeVideoDevice else { return }

      // Clamp Kelvin to valid range
      let minKelvin: Float = 2000.0
      let maxKelvin: Float = 10000.0
      let clampedKelvin = max(minKelvin, min(kelvin, maxKelvin))

      // Create temperature and tint values (neutral tint)
      let temperatureAndTint = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(
        temperature: clampedKelvin,
        tint: 0.0  // Neutral tint
      )

      // Convert to device-specific gains
      var gains = device.deviceWhiteBalanceGains(for: temperatureAndTint)

      // Clamp gains to device maximum
      gains = self.clampWhiteBalanceGains(gains, maxGain: device.maxWhiteBalanceGain)

      do {
        try device.lockForConfiguration()
        device.setWhiteBalanceModeLocked(with: gains, completionHandler: nil)
        device.unlockForConfiguration()

        // Update published state on main thread
        DispatchQueue.main.async {
          self.currentTemperatureKelvin = clampedKelvin
          self.isUsingManualWhiteBalance = true
        }
      } catch {
        print("[CameraEngine] 🚨 Failed to set white balance: \(error.localizedDescription)")
      }
    }
  }

  /// Resets white balance to continuous auto mode
  func setAutoWhiteBalance() {
    sessionQueue.async { [weak self] in
      guard let self = self, let device = self.activeVideoDevice else { return }

      do {
        try device.lockForConfiguration()

        if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
          device.whiteBalanceMode = .continuousAutoWhiteBalance
        }

        device.unlockForConfiguration()

        // Update published state on main thread
        DispatchQueue.main.async {
          self.isUsingManualWhiteBalance = false
          // Keep current temperature as display value (system-managed)
        }
      } catch {
        print("[CameraEngine] 🚨 Failed to set auto white balance: \(error.localizedDescription)")
      }
    }
  }

  /// Clamps white balance gains to valid device range (1.0 to maxGain)
  /// - Parameters:
  ///   - gains: The gains to clamp
  ///   - maxGain: The device maximum white balance gain
  /// - Returns: Clamped gains within valid range
  private func clampWhiteBalanceGains(
    _ gains: AVCaptureDevice.WhiteBalanceGains,
    maxGain: Float
  ) -> AVCaptureDevice.WhiteBalanceGains {
    return AVCaptureDevice.WhiteBalanceGains(
      redGain: max(1.0, min(gains.redGain, maxGain)),
      greenGain: max(1.0, min(gains.greenGain, maxGain)),
      blueGain: max(1.0, min(gains.blueGain, maxGain))
    )
  }

  // MARK: - Zoom Control

  /// Sets the zoom factor with a smooth ramp
  /// - Parameter factor: The target zoom factor
  func setZoomFactor(_ factor: CGFloat) {
    sessionQueue.async { [weak self] in
      guard let self = self, let device = self.activeVideoDevice else { return }

      // Clamp to available range
      let minZoom = device.minAvailableVideoZoomFactor
      let maxZoom = device.maxAvailableVideoZoomFactor
      let clampedFactor = max(minZoom, min(factor, maxZoom))

      do {
        try device.lockForConfiguration()
        // Use ramp for smooth transition
        device.ramp(toVideoZoomFactor: clampedFactor, withRate: self.zoomRampRate)

        // AC4: Manual Focus Reset - Revert to auto-focus on lens switch
        if device.focusMode == .locked && device.isFocusModeSupported(.continuousAutoFocus) {
          device.focusMode = .continuousAutoFocus
        }

        device.unlockForConfiguration()

        DispatchQueue.main.async {
          self.currentZoomFactor = clampedFactor

          // Update focus state UI if it was manual
          if self.isUsingManualFocus {
            self.isUsingManualFocus = false
          }
        }
      } catch {
        print("[CameraEngine] 🚨 Failed to set zoom factor: \(error.localizedDescription)")
      }
    }
  }

  /// Updates available lens factors based on the active device
  private func updateZoomCapabilities() {
    guard let device = activeVideoDevice else { return }

    // Calculate available lens factors
    // If virtual device, use switchOver factors to determine logical lenses
    var factors: [CGFloat] = []

    // Always start with min factor (usually 0.5 or 1.0)
    let minZoom = device.minAvailableVideoZoomFactor
    factors.append(minZoom)

    // Add switch over points
    let switchOverFactors = device.virtualDeviceSwitchOverVideoZoomFactors.map {
      CGFloat($0.floatValue)
    }
    factors.append(contentsOf: switchOverFactors)

    // Deduplicate and Sort
    let uniqueFactors = Array(Set(factors)).sorted()

    DispatchQueue.main.async {
      self.availableLensFactors = uniqueFactors.isEmpty ? [1.0] : uniqueFactors
      self.currentZoomFactor = device.videoZoomFactor
    }
  }

  // MARK: - Exposure Observation

  private func startObservingExposureValues() {
    guard let device = activeVideoDevice as? NSObject else { return }

    device.addObserver(self, forKeyPath: "iso", options: [.new], context: &exposureContext)
    device.addObserver(
      self, forKeyPath: "exposureDuration", options: [.new], context: &exposureContext)
    device.addObserver(self, forKeyPath: "lensAperture", options: [.new], context: &exposureContext)
  }

  private func stopObservingExposureValues() {
    guard let device = activeVideoDevice as? NSObject else { return }

    // Use try-catch or safe removal if possible, but standard is remove on deinit or change
    // Since activeVideoDevice doesn't change often, verify we only remove if added.
    // For simplicity in this implementation, we assume balanced calls or remove on deinit/stop.
    device.removeObserver(self, forKeyPath: "iso", context: &exposureContext)
    device.removeObserver(self, forKeyPath: "exposureDuration", context: &exposureContext)
    device.removeObserver(self, forKeyPath: "lensAperture", context: &exposureContext)
  }

  override func observeValue(
    forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?
  ) {
    guard context == &exposureContext else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
      return
    }

    guard let device = object as? CaptureDeviceProtocol else { return }

    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }

      switch keyPath {
      case "iso":
        self.currentISO = device.iso
      case "exposureDuration":
        self.currentExposureDuration = device.exposureDuration
      case "lensAperture":
        self.currentAperture = device.lensAperture
      default:
        break
      }
    }
  }
}
