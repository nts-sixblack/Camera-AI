//
//  ViewfinderViewModelTests.swift
//  CameraTests
//
//  Tests for the ViewfinderViewModel state management
//

import XCTest

@testable import Camera

@MainActor
final class ViewfinderViewModelTests: XCTestCase {

  // MARK: - Initial State Tests

  func testInitialState_IsIdle() async {
    // Note: ViewfinderViewModel uses CameraEngine.shared which may have state
    // from previous tests. We test the expected initial state for a fresh app launch.
    let viewModel = ViewfinderViewModel()

    // The initial state should be idle for a new viewModel
    // (shared engine state doesn't affect viewModel's own state)
    XCTAssertEqual(viewModel.state, .idle)
  }

  // MARK: - Stop Camera Tests

  func testStopCamera_TransitionsToIdle() async {
    // Given
    let viewModel = ViewfinderViewModel()

    // When
    await viewModel.stopCamera()

    // Then
    XCTAssertEqual(viewModel.state, .idle)
  }

  // MARK: - Background/Foreground Tests

  func testPauseForBackground_WhenNotReady_DoesNothing() async {
    // Given
    let viewModel = ViewfinderViewModel()
    // Don't start camera - state is .idle

    // When
    await viewModel.pauseForBackground()

    // Then
    XCTAssertEqual(viewModel.state, .idle)
  }

  func testResumeFromBackground_WhenNotReady_DoesNothing() async {
    // Given
    let viewModel = ViewfinderViewModel()
    // State is .idle

    // When
    await viewModel.resumeFromBackground()

    // Then
    XCTAssertEqual(viewModel.state, .idle)
  }

  // MARK: - Loading Indicator Tests

  func testLoadingIndicator_InitiallyFalse() async {
    // Given/When
    let viewModel = ViewfinderViewModel()

    // Then
    XCTAssertFalse(viewModel.showLoadingIndicator)
  }
}
