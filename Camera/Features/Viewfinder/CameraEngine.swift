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

  func isFocusModeSupported(_ focusMode: AVCaptureDevice.FocusMode) -> Bool
  func isExposureModeSupported(_ exposureMode: AVCaptureDevice.ExposureMode) -> Bool
  func isWhiteBalanceModeSupported(_ whiteBalanceMode: AVCaptureDevice.WhiteBalanceMode) -> Bool

  func lockForConfiguration() throws
  func unlockForConfiguration()
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
final class CameraEngine: @unchecked Sendable {

  // MARK: - Shared Instance for Early Initialization

  /// Shared instance for pre-warming during app launch
  static let shared = CameraEngine()

  // MARK: - Properties

  /// Current state of the camera engine
  @Published private(set) var state: CameraEngineState = .idle

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
    guard
      let videoDevice = deviceProvider.defaultDevice(
        for: .builtInWideAngleCamera,
        mediaType: .video,
        position: .back
      )
    else {
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

    } catch {
      captureSession.commitConfiguration()
      updateState(.error("Failed to create video input: \(error.localizedDescription)"))
      return
    }

    captureSession.commitConfiguration()
    isConfigured = true
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
      } catch {
        print("[CameraEngine] 🚨 Failed to reset to auto: \(error.localizedDescription)")
      }
    }
  }
}
