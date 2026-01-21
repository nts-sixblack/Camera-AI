//
//  FocusDialTests.swift
//  CameraTests
//
//  Unit tests for FocusDistance helper and FocusDialViewModel.
//

import XCTest

@testable import Camera

final class FocusDialTests: XCTestCase {

  // MARK: - FocusDistance.displayString Tests

  func testDisplayStringAtNearMinimum() {
    let result = FocusDistance.displayString(from: 0.0)
    XCTAssertEqual(result, "0.1m")
  }

  func testDisplayStringAtMacroRange() {
    let result = FocusDistance.displayString(from: 0.15)
    XCTAssertEqual(result, "0.3m")
  }

  func testDisplayStringAtMidRange() {
    let result = FocusDistance.displayString(from: 0.5)
    XCTAssertEqual(result, "1m")
  }

  func testDisplayStringAtFarRange() {
    let result = FocusDistance.displayString(from: 0.75)
    XCTAssertEqual(result, "2m")
  }

  func testDisplayStringAtInfinity() {
    let result = FocusDistance.displayString(from: 1.0)
    XCTAssertEqual(result, "∞")
  }

  func testDisplayStringAt095() {
    // At 0.95 should transition to infinity
    let result = FocusDistance.displayString(from: 0.95)
    XCTAssertEqual(result, "∞")
  }

  // M2 fix: Edge case tests for exact boundary values
  func testDisplayStringAtExactBoundaries() {
    // Values at exact boundaries should fall into expected ranges
    XCTAssertEqual(FocusDistance.displayString(from: 0.1), "0.3m")  // 0.1 is in 0.1..<0.2
    XCTAssertEqual(FocusDistance.displayString(from: 0.2), "0.5m")  // 0.2 is in 0.2..<0.4
    XCTAssertEqual(FocusDistance.displayString(from: 0.4), "1m")  // 0.4 is in 0.4..<0.6
    XCTAssertEqual(FocusDistance.displayString(from: 0.6), "2m")  // 0.6 is in 0.6..<0.8
    XCTAssertEqual(FocusDistance.displayString(from: 0.8), "5m")  // 0.8 is in 0.8..<0.95
  }

  func testDisplayStringWithNegativeValue() {
    // Negative values should return "0.1m" (falls into default after all cases fail)
    let result = FocusDistance.displayString(from: -0.5)
    XCTAssertEqual(result, "0.1m")  // Falls into 0.0..<0.1 range check fails, default ∞? Actually no...
  }

  // MARK: - FocusDialViewModel Init Tests

  func testViewModelInitializesWithCorrectPosition() {
    let viewModel = FocusDialViewModel(currentLensPosition: 0.5)
    XCTAssertEqual(viewModel.currentLensPosition, 0.5, accuracy: 0.001)
  }

  func testViewModelClampsInitialPositionToMinBound() {
    // H2 fix: init NOW clamps
    let viewModel = FocusDialViewModel(currentLensPosition: -0.5)
    XCTAssertEqual(viewModel.currentLensPosition, 0.0, accuracy: 0.001)
  }

  func testViewModelClampsInitialPositionToMaxBound() {
    // H2 fix: init NOW clamps
    let viewModel = FocusDialViewModel(currentLensPosition: 1.5)
    XCTAssertEqual(viewModel.currentLensPosition, 1.0, accuracy: 0.001)
  }

  // MARK: - FocusDialViewModel Gesture Tests

  func testViewModelCallsCallbackOnChange() {
    let viewModel = FocusDialViewModel(currentLensPosition: 0.5)

    var callbackCalled = false
    var lastPosition: Float = 0
    viewModel.onLensPositionChanged = { position in
      callbackCalled = true
      lastPosition = position
    }

    viewModel.onDragStart()
    viewModel.onDragChange(translation: -50)  // Swipe up = increase lens position
    viewModel.onDragEnd()

    XCTAssertTrue(callbackCalled)
    XCTAssertGreaterThan(lastPosition, 0.5)
  }

  func testSwipeUpIncreasesLensPosition() {
    let viewModel = FocusDialViewModel(currentLensPosition: 0.5)

    viewModel.onDragStart()
    viewModel.onDragChange(translation: -60)  // Negative = swipe up = toward infinity
    viewModel.onDragEnd()

    XCTAssertGreaterThan(viewModel.currentLensPosition, 0.5)
  }

  func testSwipeDownDecreasesLensPosition() {
    let viewModel = FocusDialViewModel(currentLensPosition: 0.5)

    viewModel.onDragStart()
    viewModel.onDragChange(translation: 60)  // Positive = swipe down = toward near
    viewModel.onDragEnd()

    XCTAssertLessThan(viewModel.currentLensPosition, 0.5)
  }

  // MARK: - FocusDialViewModel Bounds Tests

  func testViewModelRespectsMinBound() {
    let viewModel = FocusDialViewModel(currentLensPosition: 0.05)

    viewModel.onDragStart()
    viewModel.onDragChange(translation: 1000)  // Large swipe down
    viewModel.onDragEnd()

    XCTAssertEqual(viewModel.currentLensPosition, 0.0, accuracy: 0.001)
  }

  func testViewModelRespectsMaxBound() {
    let viewModel = FocusDialViewModel(currentLensPosition: 0.95)

    viewModel.onDragStart()
    viewModel.onDragChange(translation: -1000)  // Large swipe up
    viewModel.onDragEnd()

    XCTAssertEqual(viewModel.currentLensPosition, 1.0, accuracy: 0.001)
  }

  // MARK: - FocusDialViewModel Update Tests

  func testUpdateLensPositionClampsToValidRange() {
    let viewModel = FocusDialViewModel(currentLensPosition: 0.5)

    viewModel.updateLensPosition(1.5)
    XCTAssertEqual(viewModel.currentLensPosition, 1.0, accuracy: 0.001)

    viewModel.updateLensPosition(-0.5)
    XCTAssertEqual(viewModel.currentLensPosition, 0.0, accuracy: 0.001)
  }

  func testUpdateLensPositionDoesNotTriggerCallbackDirectly() {
    let viewModel = FocusDialViewModel(currentLensPosition: 0.5)

    var callbackCalled = false
    viewModel.onLensPositionChanged = { _ in
      callbackCalled = true
    }

    // updateLensPosition is for external updates (from camera), should not trigger callback
    // The callback is only for user gestures
    viewModel.updateLensPosition(0.7)

    XCTAssertFalse(callbackCalled)
    XCTAssertEqual(viewModel.currentLensPosition, 0.7, accuracy: 0.001)
  }
}
