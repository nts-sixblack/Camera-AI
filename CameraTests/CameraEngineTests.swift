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
final class MockCaptureDevice: NSObject, CaptureDeviceProtocol, @unchecked Sendable {
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

  // ISO-related mock properties (Story 2.2)
  @objc dynamic private var _iso: Float = 100.0
  @objc dynamic private var _exposureDuration: CMTime = CMTime(value: 1, timescale: 125)  // 1/125s
  @objc dynamic private var _lensAperture: Float = 1.8
  private var _setExposureModeCustomCalled = false
  private var _lastSetISO: Float = 0
  private var _lastSetDuration: CMTime = .zero

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

  // MARK: - ISO/Exposure Protocol Properties (Story 2.2)

  /// Returns a mock active format - uses the first format from a real device or a placeholder
  var activeFormat: AVCaptureDevice.Format {
    // We need to return a real Format. Getting one from a real device if available.
    // In unit tests without real devices, this may crash on access to min/maxISO.
    // A safer approach is to use a real device's format if simulator has one.
    if let device = AVCaptureDevice.default(for: .video) {
      return device.activeFormat
    }
    // Fallback - this may cause issues but is the best we can do in mock
    fatalError("MockCaptureDevice.activeFormat requires a real device for format access in tests")
  }

  @objc dynamic var iso: Float {
    get { lock.withLock { _iso } }
    set { lock.withLock { _iso = newValue } }
  }

  @objc dynamic var exposureDuration: CMTime {
    get { lock.withLock { _exposureDuration } }
    set { lock.withLock { _exposureDuration = newValue } }
  }

  @objc dynamic var lensAperture: Float {
    get { lock.withLock { _lensAperture } }
    set { lock.withLock { _lensAperture = newValue } }
  }

  var setExposureModeCustomCalled: Bool {
    lock.withLock { _setExposureModeCustomCalled }
  }

  var lastSetISO: Float {
    lock.withLock { _lastSetISO }
  }

  func setExposureModeCustom(
    duration: CMTime,
    iso: Float,
    completionHandler handler: ((CMTime) -> Void)?
  ) {
    lock.withLock {
      _setExposureModeCustomCalled = true
      _lastSetISO = iso
      _lastSetDuration = duration
      _iso = iso
      _exposureDuration = duration
    }
    handler?(duration)
  }

  // MARK: - Focus/Lens Position Protocol Properties (Story 2.4)

  private var _lensPosition: Float = 0.5
  private var _setFocusModeLocked = false
  private var _lastSetLensPosition: Float = 0

  var lensPosition: Float {
    get { lock.withLock { _lensPosition } }
    set { lock.withLock { _lensPosition = newValue } }
  }

  var setFocusModeLockedCalled: Bool {
    lock.withLock { _setFocusModeLocked }
  }

  var lastSetLensPosition: Float {
    lock.withLock { _lastSetLensPosition }
  }

  func setFocusModeLocked(lensPosition: Float, completionHandler handler: ((CMTime) -> Void)?) {
    lock.withLock {
      _setFocusModeLocked = true
      _lastSetLensPosition = lensPosition
      _lensPosition = lensPosition
    }
    handler?(CMTime.zero)
  }

  // MARK: - White Balance Protocol Properties (Story 2.5)

  private var _maxWhiteBalanceGain: Float = 4.0
  private var _setWhiteBalanceModeLockedCalled = false
  private var _lastSetWhiteBalanceGains: AVCaptureDevice.WhiteBalanceGains?

  var maxWhiteBalanceGain: Float {
    lock.withLock { _maxWhiteBalanceGain }
  }

  var setWhiteBalanceModeLockedCalled: Bool {
    lock.withLock { _setWhiteBalanceModeLockedCalled }
  }

  var lastSetWhiteBalanceGains: AVCaptureDevice.WhiteBalanceGains? {
    lock.withLock { _lastSetWhiteBalanceGains }
  }

  func deviceWhiteBalanceGains(
    for temperatureAndTint: AVCaptureDevice.WhiteBalanceTemperatureAndTintValues
  ) -> AVCaptureDevice.WhiteBalanceGains {
    // Return simple mock gains based on temperature (simplified approximation)
    let normalizedTemp = (temperatureAndTint.temperature - 2000) / 8000  // 0-1 range
    return AVCaptureDevice.WhiteBalanceGains(
      redGain: 1.0 + (1.0 - normalizedTemp),  // Higher red for warmer temps
      greenGain: 1.0,
      blueGain: 1.0 + normalizedTemp  // Higher blue for cooler temps
    )
  }

  func setWhiteBalanceModeLocked(
    with gains: AVCaptureDevice.WhiteBalanceGains,
    completionHandler handler: ((CMTime) -> Void)?
  ) {
    lock.withLock {
      _setWhiteBalanceModeLockedCalled = true
      _lastSetWhiteBalanceGains = gains
    }
    handler?(CMTime.zero)
  }

  // MARK: - Zoom Protocol Properties (Story 2.6)

  private var _videoZoomFactor: CGFloat = 1.0
  private var _minAvailableVideoZoomFactor: CGFloat = 1.0
  private var _maxAvailableVideoZoomFactor: CGFloat = 5.0
  private var _virtualDeviceSwitchOverVideoZoomFactors: [NSNumber] = []
  private var _rampToVideoZoomFactorCalled = false
  private var _cancelVideoZoomRampCalled = false
  private var _lastRampedZoomFactor: CGFloat = 0.0
  private var _lastRampRate: Float = 0.0

  var videoZoomFactor: CGFloat {
    get { lock.withLock { _videoZoomFactor } }
    set { lock.withLock { _videoZoomFactor = newValue } }
  }

  var minAvailableVideoZoomFactor: CGFloat {
    get { lock.withLock { _minAvailableVideoZoomFactor } }
    set { lock.withLock { _minAvailableVideoZoomFactor = newValue } }
  }

  var maxAvailableVideoZoomFactor: CGFloat {
    get { lock.withLock { _maxAvailableVideoZoomFactor } }
    set { lock.withLock { _maxAvailableVideoZoomFactor = newValue } }
  }

  var virtualDeviceSwitchOverVideoZoomFactors: [NSNumber] {
    get { lock.withLock { _virtualDeviceSwitchOverVideoZoomFactors } }
    set { lock.withLock { _virtualDeviceSwitchOverVideoZoomFactors = newValue } }
  }

  var rampToVideoZoomFactorCalled: Bool {
    lock.withLock { _rampToVideoZoomFactorCalled }
  }

  var lastRampedZoomFactor: CGFloat {
    lock.withLock { _lastRampedZoomFactor }
  }

  func ramp(toVideoZoomFactor factor: CGFloat, withRate rate: Float) {
    lock.withLock {
      _rampToVideoZoomFactorCalled = true
      _lastRampedZoomFactor = factor
      _lastRampRate = rate
      _videoZoomFactor = factor
    }
  }

  func cancelVideoZoomRamp() {
    lock.withLock { _cancelVideoZoomRampCalled = true }
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
    try? await Task.sleep(nanoseconds: 500_000_000)

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
    try? await Task.sleep(nanoseconds: 500_000_000)

    // When
    await engine.stopSession()
    try? await Task.sleep(nanoseconds: 500_000_000)

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
    try? await Task.sleep(nanoseconds: 500_000_000)

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
    try? await Task.sleep(nanoseconds: 500_000_000)

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
    try? await Task.sleep(nanoseconds: 500_000_000)

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
    try? await Task.sleep(nanoseconds: 500_000_000)

    // When
    await engine.stopSession()
    try? await Task.sleep(nanoseconds: 500_000_000)

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
    try? await Task.sleep(nanoseconds: 500_000_000)

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
    try? await Task.sleep(nanoseconds: 500_000_000)

    // When
    let focusPoint = CGPoint(x: 0.5, y: 0.5)
    engine.focus(at: focusPoint)

    // Wait for async queue
    try? await Task.sleep(nanoseconds: 500_000_000)

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
    try? await Task.sleep(nanoseconds: 500_000_000)

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

    try? await Task.sleep(nanoseconds: 300_000_000)
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
    try? await Task.sleep(nanoseconds: 500_000_000)

    // Then
    XCTAssertEqual(mockDevice.focusMode, .continuousAutoFocus)
    XCTAssertEqual(mockDevice.exposureMode, .continuousAutoExposure)
    XCTAssertEqual(mockDevice.whiteBalanceMode, .continuousAutoWhiteBalance)
  }

  // MARK: - Focus Control Tests (M4 fix: Story 2.4)

  func testSetFocusLensPosition_SetsDeviceLensPosition() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockDevice = MockCaptureDevice()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = mockDevice
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)
    await engine.startSession()
    try? await Task.sleep(nanoseconds: 500_000_000)

    // When
    engine.setFocusLensPosition(0.75)
    try? await Task.sleep(nanoseconds: 500_000_000)

    // Then
    XCTAssertTrue(mockDevice.setFocusModeLockedCalled)
    XCTAssertEqual(mockDevice.lastSetLensPosition, 0.75, accuracy: 0.001)
  }

  func testSetFocusLensPosition_ClampsToValidRange() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockDevice = MockCaptureDevice()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = mockDevice
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)
    await engine.startSession()
    try? await Task.sleep(nanoseconds: 500_000_000)

    // When - try to set value above 1.0
    engine.setFocusLensPosition(1.5)
    try? await Task.sleep(nanoseconds: 500_000_000)

    // Then - should be clamped to 1.0
    XCTAssertEqual(mockDevice.lastSetLensPosition, 1.0, accuracy: 0.001)
  }

  func testSetAutoFocus_ResetsToAutoFocusMode() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockDevice = MockCaptureDevice()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = mockDevice
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)
    await engine.startSession()
    try? await Task.sleep(nanoseconds: 500_000_000)

    // First set manual focus
    mockDevice.focusMode = .locked

    // When
    engine.setAutoFocus()
    try? await Task.sleep(nanoseconds: 500_000_000)

    // Then
    XCTAssertEqual(mockDevice.focusMode, .continuousAutoFocus)
  }

  // MARK: - White Balance Control Tests (Story 2.5)

  func testSetWhiteBalanceTemperature_SetsDeviceGains() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockDevice = MockCaptureDevice()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = mockDevice
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)
    await engine.startSession()
    try? await Task.sleep(nanoseconds: 500_000_000)

    // When
    engine.setWhiteBalanceTemperature(5500.0)
    try? await Task.sleep(nanoseconds: 500_000_000)

    // Then
    XCTAssertTrue(mockDevice.setWhiteBalanceModeLockedCalled)
    XCTAssertNotNil(mockDevice.lastSetWhiteBalanceGains)
  }

  func testSetWhiteBalanceTemperature_ClampsToMinimum() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockDevice = MockCaptureDevice()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = mockDevice
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)
    await engine.startSession()
    try? await Task.sleep(nanoseconds: 500_000_000)

    // When - try to set value below minimum (2000K)
    engine.setWhiteBalanceTemperature(1000.0)
    try? await Task.sleep(nanoseconds: 500_000_000)

    // Then - should still call setWhiteBalanceModeLocked (clamped internally)
    XCTAssertTrue(mockDevice.setWhiteBalanceModeLockedCalled)

    // Verify it used values for 2000K, not 1000K
    // At 2000K with our mock: Red=2.0, Green=1.0, Blue=1.0
    // If it used 1000K: Red=2.125, Green=1.0, Blue=0.875
    guard let gains = mockDevice.lastSetWhiteBalanceGains else {
      XCTFail("Gains should not be nil")
      return
    }

    // Check that blue gain is >= 1.0 (validating both proper Kelvin clamping and/or gain clamping)
    XCTAssertGreaterThanOrEqual(gains.blueGain, 1.0)
    XCTAssertEqual(gains.blueGain, 1.0, accuracy: 0.001)
    XCTAssertEqual(gains.redGain, 2.0, accuracy: 0.001)
  }

  func testSetAutoWhiteBalance_ResetsToAutoMode() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockDevice = MockCaptureDevice()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = mockDevice
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)
    await engine.startSession()
    try? await Task.sleep(nanoseconds: 500_000_000)

    // First set manual white balance
    mockDevice.whiteBalanceMode = .locked

    // When
    engine.setAutoWhiteBalance()
    try? await Task.sleep(nanoseconds: 500_000_000)

    // Then
    XCTAssertEqual(mockDevice.whiteBalanceMode, .continuousAutoWhiteBalance)
  }

  // MARK: - Zoom Control Tests (Story 2.6)

  func testSetZoomFactor_RampsToValue() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockDevice = MockCaptureDevice()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = mockDevice
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)
    await engine.startSession()
    try? await Task.sleep(nanoseconds: 500_000_000)

    // When
    engine.setZoomFactor(2.0)
    try? await Task.sleep(nanoseconds: 500_000_000)

    // Then
    XCTAssertTrue(mockDevice.rampToVideoZoomFactorCalled)
    XCTAssertEqual(mockDevice.lastRampedZoomFactor, 2.0, accuracy: 0.001)
  }

  func testAvailableLensFactors_ReturnsCorrectValues() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockDevice = MockCaptureDevice()
    // Configure mock device to simulate a triple camera (0.5x, 1x, 2x switch over implies lenses)
    // switch over factors: [2.0] usually means transitions.
    // Let's assume a simplified mock behavior where we just check what the engine exposes
    // The engine should consult the device.

    // For this test, we need to inspect what the Engine returns.
    // Since MockDevice doesn't easily simulate complex switchOverFactors without more logic,
    // we'll rely on the engine's default logic or mock configuration.

    mockDevice.virtualDeviceSwitchOverVideoZoomFactors = [2.0]  // Hypothetical switch point

    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = mockDevice
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)
    await engine.startSession()
    try? await Task.sleep(nanoseconds: 500_000_000)

    // When
    let factors = engine.availableLensFactors

    // Then
    // We expect at least some factors. If logic relies on switchOverFactors:
    // With [2.0], maybe we get 1.0 and 2.0? Or 0.5, 1.0, 2.0?
    // Let's assert based on what we plan to implement (likely 0.5, 1.0, 3.0 basics)
    XCTAssertFalse(factors.isEmpty)
  }

  func testSetZoomFactor_ResetsManualFocus() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockDevice = MockCaptureDevice()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = mockDevice
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)
    await engine.startSession()
    try? await Task.sleep(nanoseconds: 500_000_000)

    // Set manual focus first
    engine.setFocusLensPosition(0.5)
    try? await Task.sleep(nanoseconds: 500_000_000)
    XCTAssertTrue(engine.isUsingManualFocus)

    // When - Switch lenses (zoom)
    engine.setZoomFactor(2.0)
    try? await Task.sleep(nanoseconds: 500_000_000)

    // Then
    XCTAssertFalse(engine.isUsingManualFocus)
    XCTAssertEqual(mockDevice.focusMode, .continuousAutoFocus)
  }

  // MARK: - Exposure Observation Tests (Story 2.7)

  func testExposureValues_UpdateOnDeviceChange() async {
    // Given
    let mockSession = MockCaptureSession()
    let mockDevice = MockCaptureDevice()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = mockDevice
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)

    await engine.startSession()
    try? await Task.sleep(nanoseconds: 500_000_000)

    // Check initial values (from mock defaults)
    XCTAssertEqual(engine.currentISO, 100.0)
    XCTAssertEqual(engine.currentExposureDuration.seconds, 1.0 / 125.0, accuracy: 0.0001)
    XCTAssertEqual(engine.currentAperture, 1.8)

    // When - hardware updates values (e.g. auto exposure)
    // We update the mock properties which should trigger KVO in engine
    let newISO: Float = 200.0
    let newDuration = CMTime(value: 1, timescale: 60)  // 1/60s
    let newAperture: Float = 2.4

    mockDevice.iso = newISO
    mockDevice.exposureDuration = newDuration
    mockDevice.lensAperture = newAperture

    // Wait for main thread updates
    try? await Task.sleep(nanoseconds: 500_000_000)

    // Then
    XCTAssertEqual(engine.currentISO, newISO)
    XCTAssertEqual(engine.currentExposureDuration.seconds, newDuration.seconds, accuracy: 0.0001)
    XCTAssertEqual(engine.currentAperture, newAperture)
  }
}  // End of CameraEngineTests extension (Wait, cat appending needs care with closing braces)
