import AVFoundation
import SwiftUI
import XCTest

@testable import Camera

@MainActor
final class CameraModeTests: XCTestCase {

  var defaults: UserDefaults!
  var suiteName: String!
  var mockEngine: CameraEngine!

  override func setUp() {
    super.setUp()
    suiteName = UUID().uuidString
    defaults = UserDefaults(suiteName: suiteName)
    defaults.removePersistentDomain(forName: suiteName)

    // Create a safe mock engine for tests
    let mockSession = MockCaptureSession()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = MockCaptureDevice()
    mockEngine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)
  }

  override func tearDown() {
    defaults.removePersistentDomain(forName: suiteName)
    mockEngine = nil
    super.tearDown()
  }

  func testInitialModeIsAuto() {
    let viewModel = ViewfinderViewModel(cameraEngine: mockEngine, userDefaults: defaults)
    XCTAssertEqual(viewModel.mode, .auto)
  }

  func testToggleMode_SwitchesBetweenAutoAndPro() {
    let viewModel = ViewfinderViewModel(cameraEngine: mockEngine, userDefaults: defaults)

    viewModel.toggleMode()
    XCTAssertEqual(viewModel.mode, .pro)

    viewModel.toggleMode()
    XCTAssertEqual(viewModel.mode, .auto)
  }

  func testPersistence_RestoresProMode() {
    // Arrange: Simulate a previously saved state
    defaults.set("pro", forKey: "com.camera.lastShootingMode")

    // Act: Initialize a new ViewModel with the SAME defaults
    let viewModel = ViewfinderViewModel(cameraEngine: mockEngine, userDefaults: defaults)

    // Assert: It should restore the Pro mode
    XCTAssertEqual(viewModel.mode, .pro, "ViewModel should restore Pro mode from persistence")
  }

  func testPersistence_SavesModeChange() {
    // Arrange
    let viewModel = ViewfinderViewModel(cameraEngine: mockEngine, userDefaults: defaults)

    // Act: Change mode
    viewModel.toggleMode()  // Auto -> Pro

    // Assert: Check UserDefaults
    let savedMode = defaults.string(forKey: "com.camera.lastShootingMode")
    XCTAssertEqual(savedMode, "pro", "Toggling mode should update UserDefaults")
  }

  func testSwitchingToAuto_ResetsEngine() async {
    // Arrange
    let mockSession = MockCaptureSession()
    let mockDevice = MockCaptureDevice()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = mockDevice
    let engine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)
    let viewModel = ViewfinderViewModel(cameraEngine: engine, userDefaults: defaults)

    // Initialize logic to set active device
    await engine.startSession()

    // Simulate manual change (Pro mode effect)
    engine.focus(at: CGPoint(x: 0.5, y: 0.5))
    try? await Task.sleep(nanoseconds: 100_000_000)

    // Pre-check: Device should be in specific mode from focus command
    XCTAssertEqual(mockDevice.focusMode, .autoFocus)  // Assuming focus() sets it to autoFocus (single shot)

    // Act
    viewModel.toggleMode()  // to Pro
    viewModel.toggleMode()  // Back to Auto

    // Wait for async operations on engine queue
    try? await Task.sleep(nanoseconds: 200_000_000)

    // Assert
    XCTAssertEqual(mockDevice.focusMode, .continuousAutoFocus)
    XCTAssertEqual(mockDevice.exposureMode, .continuousAutoExposure)
  }
}
