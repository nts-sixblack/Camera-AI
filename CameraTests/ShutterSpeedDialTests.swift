//
//  ShutterSpeedDialTests.swift
//  CameraTests
//
//  Unit tests for ShutterStops enum and ShutterSpeedDialViewModel.
//

import CoreMedia
import XCTest

@testable import Camera

final class ShutterSpeedDialTests: XCTestCase {

  // MARK: - ShutterStops.nearest Tests

  func testNearestReturnsExactMatch() {
    let duration = CMTime(value: 1, timescale: 250)
    let minDuration = CMTime(value: 1, timescale: 8000)
    let maxDuration = CMTime(value: 1, timescale: 4)

    let result = ShutterStops.nearest(
      to: duration, minDuration: minDuration, maxDuration: maxDuration)

    XCTAssertEqual(result.seconds, 1.0 / 250.0, accuracy: 0.0001)
  }

  func testNearestSnapsToClosestStop() {
    // 1/175 is between 1/200 and 1/160, should snap to 1/160 (closer)
    let duration = CMTime(seconds: 1.0 / 175.0, preferredTimescale: 1000)
    let minDuration = CMTime(value: 1, timescale: 8000)
    let maxDuration = CMTime(value: 1, timescale: 4)

    let result = ShutterStops.nearest(
      to: duration, minDuration: minDuration, maxDuration: maxDuration)

    // Should be 1/160 (0.00625) rather than 1/200 (0.005)
    XCTAssertEqual(result.seconds, 1.0 / 160.0, accuracy: 0.0001)
  }

  func testNearestRespectsMinBound() {
    // Request something faster than min
    let duration = CMTime(value: 1, timescale: 16000)  // 1/16000
    let minDuration = CMTime(value: 1, timescale: 8000)  // 1/8000
    let maxDuration = CMTime(value: 1, timescale: 4)

    let result = ShutterStops.nearest(
      to: duration, minDuration: minDuration, maxDuration: maxDuration)

    // Should be clamped to fastest valid stop: 1/8000
    XCTAssertGreaterThanOrEqual(result.seconds, minDuration.seconds)
  }

  func testNearestRespectsMaxBound() {
    // Request something slower than max
    let duration = CMTime(value: 2, timescale: 1)  // 2 seconds
    let minDuration = CMTime(value: 1, timescale: 8000)
    let maxDuration = CMTime(value: 1, timescale: 4)  // 1/4 second

    let result = ShutterStops.nearest(
      to: duration, minDuration: minDuration, maxDuration: maxDuration)

    // Should be clamped to slowest valid stop
    XCTAssertLessThanOrEqual(result.seconds, maxDuration.seconds)
  }

  // MARK: - ShutterStops.faster Tests

  func testFasterReturnsNextFasterStop() {
    // Current: 1/125, should get 1/160
    let current = CMTime(value: 1, timescale: 125)
    let minDuration = CMTime(value: 1, timescale: 8000)

    let result = ShutterStops.faster(than: current, minDuration: minDuration)

    XCTAssertNotNil(result)
    XCTAssertEqual(result!.seconds, 1.0 / 160.0, accuracy: 0.0001)
  }

  func testFasterReturnsNilAtFastestStop() {
    let current = CMTime(value: 1, timescale: 8000)
    let minDuration = CMTime(value: 1, timescale: 8000)

    let result = ShutterStops.faster(than: current, minDuration: minDuration)

    XCTAssertNil(result)
  }

  // MARK: - ShutterStops.slower Tests

  func testSlowerReturnsNextSlowerStop() {
    // Current: 1/125, should get 1/100
    let current = CMTime(value: 1, timescale: 125)
    let maxDuration = CMTime(value: 1, timescale: 1)  // 1 second

    let result = ShutterStops.slower(than: current, maxDuration: maxDuration)

    XCTAssertNotNil(result)
    XCTAssertEqual(result!.seconds, 1.0 / 100.0, accuracy: 0.0001)
  }

  func testSlowerReturnsNilAtSlowestStop() {
    let current = CMTime(value: 1, timescale: 1)  // 1 second
    let maxDuration = CMTime(value: 1, timescale: 1)

    let result = ShutterStops.slower(than: current, maxDuration: maxDuration)

    XCTAssertNil(result)
  }

  // MARK: - ShutterStops.index Tests

  func testIndexReturnsValidIndex() {
    let duration = CMTime(value: 1, timescale: 250)
    let minDuration = CMTime(value: 1, timescale: 8000)
    let maxDuration = CMTime(value: 1, timescale: 1)

    let index = ShutterStops.index(of: duration, minDuration: minDuration, maxDuration: maxDuration)

    XCTAssertNotNil(index)
    XCTAssertGreaterThan(index!, 0)
  }

  // MARK: - ShutterSpeedDialViewModel Tests

  func testViewModelInitializesWithCorrectDuration() {
    let currentDuration = CMTime(value: 1, timescale: 125)
    let minDuration = CMTime(value: 1, timescale: 8000)
    let maxDuration = CMTime(value: 1, timescale: 1)

    let viewModel = ShutterSpeedDialViewModel(
      currentDuration: currentDuration,
      minDuration: minDuration,
      maxDuration: maxDuration
    )

    XCTAssertEqual(viewModel.currentDuration.seconds, currentDuration.seconds, accuracy: 0.0001)
  }

  func testViewModelCallsCallbackOnChange() {
    let viewModel = ShutterSpeedDialViewModel(
      currentDuration: CMTime(value: 1, timescale: 125),
      minDuration: CMTime(value: 1, timescale: 8000),
      maxDuration: CMTime(value: 1, timescale: 1)
    )

    var callbackCalled = false
    viewModel.onShutterSpeedChanged = { _ in
      callbackCalled = true
    }

    viewModel.onDragStart()
    viewModel.onDragChange(translation: -50)  // Swipe up = faster
    viewModel.onDragEnd()

    XCTAssertTrue(callbackCalled)
  }

  func testViewModelUpdateDurationSnapsToNearestStop() {
    let viewModel = ShutterSpeedDialViewModel(
      currentDuration: CMTime(value: 1, timescale: 125),
      minDuration: CMTime(value: 1, timescale: 8000),
      maxDuration: CMTime(value: 1, timescale: 1)
    )

    // Update with a non-standard value
    viewModel.updateDuration(CMTime(seconds: 1.0 / 175.0, preferredTimescale: 1000))

    // Should snap to 1/160
    XCTAssertEqual(viewModel.currentDuration.seconds, 1.0 / 160.0, accuracy: 0.0001)
  }
}
