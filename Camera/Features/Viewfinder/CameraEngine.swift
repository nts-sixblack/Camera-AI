//
//  CameraEngine.swift
//  Camera
//
//  Manages AVCaptureSession lifecycle for camera preview and capture.
//  All session operations are performed on a dedicated background queue.
//

import AVFoundation
import Combine

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
    case let (.error(l), .error(r)):
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

/// Protocol for providing capture devices to enable testing
protocol CaptureDeviceProviding: Sendable {
  func defaultDevice(
    for deviceType: AVCaptureDevice.DeviceType,
    mediaType: AVMediaType,
    position: AVCaptureDevice.Position
  ) -> AVCaptureDevice?
}

/// Production implementation using AVCaptureDevice.DiscoverySession
final class ProductionCaptureDeviceProvider: CaptureDeviceProviding, Sendable {
  func defaultDevice(
    for deviceType: AVCaptureDevice.DeviceType,
    mediaType: AVMediaType,
    position: AVCaptureDevice.Position
  ) -> AVCaptureDevice? {
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

  // MARK: - Notification Observers

  private var interruptionObserver: NSObjectProtocol?
  private var interruptionEndedObserver: NSObjectProtocol?
  private var runtimeErrorObserver: NSObjectProtocol?

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

  // MARK: - Session Configuration

  private func configureSession() {
    captureSession.beginConfiguration()
    captureSession.sessionPreset = .photo

    // Add video input
    guard let videoDevice = deviceProvider.defaultDevice(
      for: .builtInWideAngleCamera,
      mediaType: .video,
      position: .back
    ) else {
      captureSession.commitConfiguration()
      updateState(.error("No camera device available"))
      return
    }

    do {
      let videoInput = try AVCaptureDeviceInput(device: videoDevice)
      if captureSession.canAddInput(videoInput) {
        captureSession.addInput(videoInput)
      } else {
        captureSession.commitConfiguration()
        updateState(.error("Could not add video input"))
        return
      }
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
}
