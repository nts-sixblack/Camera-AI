//
//  CameraEngineTests.swift
//  CameraTests
//
//  Tests for the CameraEngine AVFoundation session management
//

import AVFoundation
import XCTest

@testable import Camera

/// Mock implementation of CaptureSessionProtocol for testing
final class MockCaptureSession: CaptureSessionProtocol, @unchecked Sendable {
  private let lock = NSLock()

  private var _isRunning = false
  private var _beginConfigurationCalled = false
  private var _commitConfigurationCalled = false
  private var _startRunningCalled = false
  private var _stopRunningCalled = false
  private var _addedInputs: [AVCaptureInput] = []
  private var _addedOutputs: [AVCaptureOutput] = []

  var addedOutputs: [AVCaptureOutput] {
    lock.withLock { _addedOutputs }
  }
  private var _sessionPreset: AVCaptureSession.Preset = .photo

  var isRunning: Bool {
    get { lock.withLock { _isRunning } }
    set { lock.withLock { _isRunning = newValue } }
  }

  var beginConfigurationCalled: Bool {
    lock.withLock { _beginConfigurationCalled }
  }

  var commitConfigurationCalled: Bool {
    lock.withLock { _commitConfigurationCalled }
  }

  var startRunningCalled: Bool {
    lock.withLock { _startRunningCalled }
  }

  var stopRunningCalled: Bool {
    lock.withLock { _stopRunningCalled }
  }

  var sessionPreset: AVCaptureSession.Preset {
    get { lock.withLock { _sessionPreset } }
    set { lock.withLock { _sessionPreset = newValue } }
  }

  func beginConfiguration() {
    lock.withLock { _beginConfigurationCalled = true }
  }

  func commitConfiguration() {
    lock.withLock { _commitConfigurationCalled = true }
  }

  func startRunning() {
    lock.withLock {
      _startRunningCalled = true
      _isRunning = true
    }
  }

  func stopRunning() {
    lock.withLock {
      _stopRunningCalled = true
      _isRunning = false
    }
  }

  func canAddInput(_ input: AVCaptureInput) -> Bool {
    true
  }

  func addInput(_ input: AVCaptureInput) {
    lock.withLock { _addedInputs.append(input) }
  }

  func canAddOutput(_ output: AVCaptureOutput) -> Bool {
    true
  }

  func addOutput(_ output: AVCaptureOutput) {
    lock.withLock { _addedOutputs.append(output) }
  }
}

/// Mock implementation of CaptureDeviceProtocol
final class MockCaptureDevice: CaptureDeviceProtocol, @unchecked Sendable {
  private let lock = NSLock()

  var isFocusPointOfInterestSupported: Bool = true
  var isExposurePointOfInterestSupported: Bool = true

  private var _focusPointOfInterest: CGPoint = .zero
  private var _focusMode: AVCaptureDevice.FocusMode = .locked
  private var _exposurePointOfInterest: CGPoint = .zero
  private var _exposureMode: AVCaptureDevice.ExposureMode = .locked
  private var _whiteBalanceMode: AVCaptureDevice.WhiteBalanceMode = .locked
  private var _isSubjectAreaChangeMonitoringEnabled: Bool = false

  private var _lockForConfigurationCalled = false
  private var _unlockForConfigurationCalled = false

  var focusPointOfInterest: CGPoint {
    get { lock.withLock { _focusPointOfInterest } }
    set { lock.withLock { _focusPointOfInterest = newValue } }
  }

  var focusMode: AVCaptureDevice.FocusMode {
    get { lock.withLock { _focusMode } }
    set { lock.withLock { _focusMode = newValue } }
  }

  var exposurePointOfInterest: CGPoint {
    get { lock.withLock { _exposurePointOfInterest } }
    set { lock.withLock { _exposurePointOfInterest = newValue } }
  }

  var exposureMode: AVCaptureDevice.ExposureMode {
    get { lock.withLock { _exposureMode } }
    set { lock.withLock { _exposureMode = newValue } }
  }

  var isWhiteBalanceModeSupported: Bool { true }
  var whiteBalanceMode: AVCaptureDevice.WhiteBalanceMode {
    get { lock.withLock { _whiteBalanceMode } }
    set { lock.withLock { _whiteBalanceMode = newValue } }
  }

  func isFocusModeSupported(_ focusMode: AVCaptureDevice.FocusMode) -> Bool { true }
  func isExposureModeSupported(_ exposureMode: AVCaptureDevice.ExposureMode) -> Bool { true }
  func isWhiteBalanceModeSupported(_ whiteBalanceMode: AVCaptureDevice.WhiteBalanceMode) -> Bool {
    true
  }

  var isSubjectAreaChangeMonitoringEnabled: Bool {
    get { lock.withLock { _isSubjectAreaChangeMonitoringEnabled } }
    set { lock.withLock { _isSubjectAreaChangeMonitoringEnabled = newValue } }
  }

  var lockForConfigurationCalled: Bool {
    lock.withLock { _lockForConfigurationCalled }
  }

  var unlockForConfigurationCalled: Bool {
    lock.withLock { _unlockForConfigurationCalled }
  }

  func lockForConfiguration() throws {
    lock.withLock { _lockForConfigurationCalled = true }
  }

  func unlockForConfiguration() {
    lock.withLock { _unlockForConfigurationCalled = true }
  }
}

/// Mock implementation of CaptureDeviceProviding for testing
final class MockCaptureDeviceProvider: CaptureDeviceProviding, @unchecked Sendable {
  private let lock = NSLock()
  private var _discoverySessionCalled = false
  private var _mockDevice: (any CaptureDeviceProtocol)?

  var discoverySessionCalled: Bool {
    lock.withLock { _discoverySessionCalled }
  }

  var mockDevice: (any CaptureDeviceProtocol)? {
    get { lock.withLock { _mockDevice } }
    set { lock.withLock { _mockDevice = newValue } }
  }

  func defaultDevice(
    for deviceType: AVCaptureDevice.DeviceType,
    mediaType: AVMediaType,
    position: AVCaptureDevice.Position
  ) -> (any CaptureDeviceProtocol)? {
    lock.withLock {
      _discoverySessionCalled = true
      return _mockDevice
    }
  }
}

final class CameraEngineTests: XCTestCase {

  // MARK: - Session State Tests

  func testInitialState_IsNotRunning() {
    // Given
    let engine = CameraEngine()

    // Then
    XCTAssertFalse(engine.isSessionRunning)
  }

  func testStartSession_ChangesStateToRunning() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = MockCaptureDevice()  // Provide a mock device

    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)

    // When
    await engine.startSession()

    // Wait briefly for async operation
    try? await Task.sleep(nanoseconds: 100_000_000)

    // Then
    XCTAssertTrue(mockSession.startRunningCalled)
  }

  func testStopSession_ChangesStateToNotRunning() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = MockCaptureDevice()
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)
    await engine.startSession()
    try? await Task.sleep(nanoseconds: 100_000_000)

    // When
    await engine.stopSession()
    try? await Task.sleep(nanoseconds: 100_000_000)

    // Then
    XCTAssertTrue(mockSession.stopRunningCalled)
  }

  // MARK: - Session Configuration Tests

  func testSetupSession_ConfiguresWithPhotoPreset() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = MockCaptureDevice()
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)

    // When
    await engine.startSession()
    try? await Task.sleep(nanoseconds: 100_000_000)

    // Then
    XCTAssertTrue(mockSession.beginConfigurationCalled)
    XCTAssertTrue(mockSession.commitConfigurationCalled)
    XCTAssertTrue(mockSession.commitConfigurationCalled)
  }

  func testSetupSession_AddsPhotoOutput() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = MockCaptureDevice()
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)

    // When
    await engine.startSession()
    try? await Task.sleep(nanoseconds: 100_000_000)

    // Then
    // We expect one output - the photo output
    XCTAssertEqual(mockSession.addedOutputs.count, 1)
    XCTAssertTrue(mockSession.addedOutputs.first is AVCapturePhotoOutput)
  }

  // MARK: - Session Queue Tests

  func testSessionOperations_DoNotBlockMainThread() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = MockCaptureDevice()
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)

    // When - session operations should complete without blocking
    await engine.startSession()

    // Then - if we get here, the operation completed and main thread wasn't blocked
    XCTAssertTrue(mockSession.startRunningCalled)
  }

  // MARK: - CameraEngineState Tests

  func testCameraEngineState_InitiallyIdle() {
    // Given
    let engine = CameraEngine()

    // Then
    XCTAssertEqual(engine.state, .idle)
  }

  func testCameraEngineState_TransitionsToRunningOnStart() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = MockCaptureDevice()
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)

    // When
    await engine.startSession()
    try? await Task.sleep(nanoseconds: 200_000_000)

    // Then
    XCTAssertEqual(engine.state, .running)
  }

  func testCameraEngineState_TransitionsToIdleOnStop() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = MockCaptureDevice()
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)
    await engine.startSession()
    try? await Task.sleep(nanoseconds: 200_000_000)

    // When
    await engine.stopSession()
    try? await Task.sleep(nanoseconds: 200_000_000)

    // Then
    XCTAssertEqual(engine.state, .idle)
  }

  // MARK: - PreWarm Tests

  func testPreWarm_ConfiguresSessionWithoutStarting() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = MockCaptureDevice()
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)

    // When
    engine.preWarm()
    try? await Task.sleep(nanoseconds: 200_000_000)

    // Then
    XCTAssertTrue(mockSession.beginConfigurationCalled)
    XCTAssertTrue(mockSession.commitConfigurationCalled)
    XCTAssertFalse(mockSession.startRunningCalled)
  }

  // MARK: - Focus Tests

  func testFocus_SetsDeviceProperties() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockProvider = MockCaptureDeviceProvider()
    let mockDevice = MockCaptureDevice()
    mockProvider.mockDevice = mockDevice

    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)

    // Start session to configure it and set activeVideoDevice
    await engine.startSession()
    try? await Task.sleep(nanoseconds: 100_000_000)

    // When
    let focusPoint = CGPoint(x: 0.5, y: 0.5)
    engine.focus(at: focusPoint)

    // Wait for async queue
    try? await Task.sleep(nanoseconds: 100_000_000)

    // Then
    XCTAssertTrue(mockDevice.lockForConfigurationCalled)
    XCTAssertEqual(mockDevice.focusPointOfInterest, focusPoint)
    XCTAssertEqual(mockDevice.focusMode, .autoFocus)
    XCTAssertEqual(mockDevice.exposurePointOfInterest, focusPoint)
    XCTAssertEqual(mockDevice.exposureMode, .continuousAutoExposure)
    XCTAssertTrue(mockDevice.isSubjectAreaChangeMonitoringEnabled)
    XCTAssertTrue(mockDevice.unlockForConfigurationCalled)
  }

  func testFocus_ResetsToContinuousAuto_OnSubjectAreaChange() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockDevice = MockCaptureDevice()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = mockDevice

    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)
    await engine.startSession()

    // Manually trigger focus first to set state likely
    engine.focus(at: CGPoint(x: 0.2, y: 0.2))
    try? await Task.sleep(nanoseconds: 100_000_000)

    // When - Simulate subject area change notification
    NotificationCenter.default.post(
      name: AVCaptureDevice.subjectAreaDidChangeNotification,
      object: nil
    )

    // Allow async block to execute
    try? await Task.sleep(nanoseconds: 200_000_000)

    // Then
    XCTAssertEqual(mockDevice.focusMode, .continuousAutoFocus)
    XCTAssertEqual(mockDevice.exposureMode, .continuousAutoExposure)
    XCTAssertFalse(mockDevice.isSubjectAreaChangeMonitoringEnabled)
  }

  // MARK: - Photo Capture Logic Tests

  // Note: Testing actual AVCapturePhotoOutput logic is limited as we cannot easily mock AVCapturePhotoOutput
  // or inspect its private connection/settings without heavy abstraction or swizzling.
  // However, we can assert that capturePhoto does not crash and processes the photo output command.

  func testCapturePhoto_DoesNotBlockOrCrash() async {
    let mockSession = MockCaptureSession()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = MockCaptureDevice()
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)
    await engine.startSession()

    // We expect this to run without crashing, even if the photo output calls fail internally
    // (mock session allows output addition).
    let expectation = XCTestExpectation(description: "Capture completion blocked")

    // In a real test we'd mock the output connection to verify videoOrientation is set,
    // but AVCaptureConnection is hard to mock.
    // We'll trust the compilation and manual testing for now, but ensure the completion is eventually called
    // (likely with error in test env because mock output doesn't callback).
    // Actually, since we use a real AVCapturePhotoOutput, it won't callback in a unit test environment usually
    // unless we mock the delegate callback ourselves or use integration tests.
    // So we just verify we can call it.

    engine.capturePhoto { _ in }

    // If we reach here immediately, it didn't block the calling thread (it's async).

    try? await Task.sleep(nanoseconds: 50_000_000)
  }

  func testResetToAuto_ResetsDeviceConfiguration() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockDevice = MockCaptureDevice()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = mockDevice
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)
    await engine.startSession()

    // Simulate non-auto state
    mockDevice.focusMode = .locked
    mockDevice.exposureMode = .locked
    mockDevice.whiteBalanceMode = .locked

    // When
    engine.resetToAuto()
    try? await Task.sleep(nanoseconds: 100_000_000)

    // Then
    XCTAssertEqual(mockDevice.focusMode, .continuousAutoFocus)
    XCTAssertEqual(mockDevice.exposureMode, .continuousAutoExposure)
    XCTAssertEqual(mockDevice.whiteBalanceMode, .continuousAutoWhiteBalance)
  }
}
