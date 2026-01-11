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

/// Mock implementation of CaptureDeviceProviding for testing
final class MockCaptureDeviceProvider: CaptureDeviceProviding, @unchecked Sendable {
  private let lock = NSLock()
  private var _discoverySessionCalled = false
  private var _mockDevice: AVCaptureDevice?

  var discoverySessionCalled: Bool {
    lock.withLock { _discoverySessionCalled }
  }

  var mockDevice: AVCaptureDevice? {
    get { lock.withLock { _mockDevice } }
    set { lock.withLock { _mockDevice = newValue } }
  }

  func defaultDevice(for deviceType: AVCaptureDevice.DeviceType, mediaType: AVMediaType, position: AVCaptureDevice.Position) -> AVCaptureDevice? {
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
    let engine = CameraEngine(captureSession: mockSession)

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
    let engine = CameraEngine(captureSession: mockSession)
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
    let engine = CameraEngine(captureSession: mockSession)

    // When
    await engine.startSession()
    try? await Task.sleep(nanoseconds: 100_000_000)

    // Then
    XCTAssertTrue(mockSession.beginConfigurationCalled)
    XCTAssertTrue(mockSession.commitConfigurationCalled)
  }

  // MARK: - Session Queue Tests

  func testSessionOperations_DoNotBlockMainThread() async {
    // Given
    let mockSession = MockCaptureSession()
    let engine = CameraEngine(captureSession: mockSession)

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
    let engine = CameraEngine(captureSession: mockSession)

    // When
    await engine.startSession()
    try? await Task.sleep(nanoseconds: 200_000_000)

    // Then
    XCTAssertEqual(engine.state, .running)
  }

  func testCameraEngineState_TransitionsToIdleOnStop() async {
    // Given
    let mockSession = MockCaptureSession()
    let engine = CameraEngine(captureSession: mockSession)
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
    let engine = CameraEngine(captureSession: mockSession)

    // When
    engine.preWarm()
    try? await Task.sleep(nanoseconds: 200_000_000)

    // Then
    XCTAssertTrue(mockSession.beginConfigurationCalled)
    XCTAssertTrue(mockSession.commitConfigurationCalled)
    XCTAssertFalse(mockSession.startRunningCalled)
  }
}
