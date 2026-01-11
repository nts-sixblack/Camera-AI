//
//  CameraPerformanceTests.swift
//  CameraTests
//
//  Performance tests for camera initialization and launch time
//

import XCTest

@testable import Camera

final class CameraPerformanceTests: XCTestCase {

  // MARK: - Unit Performance Tests (using mocks)

  /// Measures time from CameraEngine creation to running state with mock session
  /// Target: < 1.5 seconds per NFR2
  func testCameraEngine_StartSession_WithMock_CompletesWithinTarget() async {
    // Given
    let mockSession = MockCaptureSession()
    let engine = CameraEngine(captureSession: mockSession)
    let targetTime: TimeInterval = 1.5  // NFR2: < 1.5s

    // When
    let startTime = CFAbsoluteTimeGetCurrent()
    await engine.startSession()
    let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime

    // Then
    XCTAssertLessThan(
      elapsedTime, targetTime,
      "Camera session should start within \(targetTime)s, took \(elapsedTime)s")
  }

  /// Measures time for preWarm followed by startSession with mock
  func testCameraEngine_PreWarmThenStart_WithMock_CompletesWithinTarget() async {
    // Given
    let mockSession = MockCaptureSession()
    let engine = CameraEngine(captureSession: mockSession)
    let targetTime: TimeInterval = 1.5  // NFR2: < 1.5s

    // Pre-warm the session
    engine.preWarm()
    try? await Task.sleep(nanoseconds: 200_000_000)  // Wait for pre-warm to complete

    // When
    let startTime = CFAbsoluteTimeGetCurrent()
    await engine.startSession()
    let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime

    // Then
    XCTAssertLessThan(
      elapsedTime, targetTime,
      "Pre-warmed camera session should start within \(targetTime)s, took \(elapsedTime)s")
  }

  /// Measures time for background resume with mock
  /// Target: < 500ms per AC3
  func testCameraEngine_ResumeFromBackground_WithMock_CompletesWithin500ms() async {
    // Given
    let mockSession = MockCaptureSession()
    let engine = CameraEngine(captureSession: mockSession)
    let targetTime: TimeInterval = 0.5  // AC3: < 500ms

    // Start session first
    await engine.startSession()

    // Simulate background
    await engine.stopSession()

    // When - resume from background
    let startTime = CFAbsoluteTimeGetCurrent()
    await engine.startSession()
    let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime

    // Then
    XCTAssertLessThan(
      elapsedTime, targetTime,
      "Camera resume should complete within \(targetTime)s, took \(elapsedTime)s")
  }

  // MARK: - Performance Measurement Tests

  func testPerformance_CameraEngineStartSession_WithMock() {
    let mockSession = MockCaptureSession()
    let engine = CameraEngine(captureSession: mockSession)

    measure {
      let expectation = expectation(description: "Session started")

      Task {
        await engine.startSession()
        await engine.stopSession()
        expectation.fulfill()
      }

      wait(for: [expectation], timeout: 5.0)
    }
  }
}
