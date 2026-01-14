//
//  ViewfinderViewModelTests.swift
//  CameraTests
//
//  Tests for the ViewfinderViewModel state management
//

import Photos
import XCTest

@testable import Camera

/// Mock Photo Library Permission Manager
final class ViewfinderMockPermissionManager: PhotoLibraryPermissionManaging, @unchecked Sendable {
  private let lock = NSLock()
  private var _checkStatus: PhotoLibraryAuthorizationState = .notDetermined
  private var _requestResult: PhotoLibraryAuthorizationState = .notDetermined
  private var _checkStatusCalled = false
  private var _requestAccessCalled = false

  var checkStatus: PhotoLibraryAuthorizationState {
    get { lock.withLock { _checkStatus } }
    set { lock.withLock { _checkStatus = newValue } }
  }

  var requestResult: PhotoLibraryAuthorizationState {
    get { lock.withLock { _requestResult } }
    set { lock.withLock { _requestResult = newValue } }
  }

  var checkStatusCalled: Bool {
    get { lock.withLock { _checkStatusCalled } }
    set { lock.withLock { _checkStatusCalled = newValue } }
  }

  var requestAccessCalled: Bool {
    get { lock.withLock { _requestAccessCalled } }
    set { lock.withLock { _requestAccessCalled = newValue } }
  }

  func checkAuthorizationStatus() -> PhotoLibraryAuthorizationState {
    checkStatusCalled = true
    return checkStatus
  }

  func requestAccess() async -> PhotoLibraryAuthorizationState {
    requestAccessCalled = true
    return requestResult
  }
}

@MainActor
final class ViewfinderViewModelTests: XCTestCase {

  // MARK: - Initial State Tests

  func testInitialState_IsIdle() async {
    let mockManager = ViewfinderMockPermissionManager()
    let viewModel = ViewfinderViewModel(photoLibraryPermissionManager: mockManager)

    XCTAssertEqual(viewModel.state, .idle)
    XCTAssertFalse(viewModel.isPhotoLibraryAccessDenied)
  }

  // MARK: - Stop Camera Tests

  func testStopCamera_TransitionsToIdle() async {
    let mockManager = ViewfinderMockPermissionManager()
    let viewModel = ViewfinderViewModel(photoLibraryPermissionManager: mockManager)

    await viewModel.stopCamera()

    XCTAssertEqual(viewModel.state, .idle)
  }

  // MARK: - Background/Foreground Tests

  func testPauseForBackground_WhenNotReady_DoesNothing() async {
    let mockManager = ViewfinderMockPermissionManager()
    let viewModel = ViewfinderViewModel(photoLibraryPermissionManager: mockManager)

    await viewModel.pauseForBackground()

    XCTAssertEqual(viewModel.state, .idle)
  }

  func testResumeFromBackground_WhenNotReady_DoesNothing() async {
    let mockManager = ViewfinderMockPermissionManager()
    let viewModel = ViewfinderViewModel(photoLibraryPermissionManager: mockManager)

    await viewModel.resumeFromBackground()

    XCTAssertEqual(viewModel.state, .idle)
  }

  // MARK: - Loading Indicator Tests

  func testLoadingIndicator_InitiallyFalse() async {
    let mockManager = ViewfinderMockPermissionManager()
    let viewModel = ViewfinderViewModel(photoLibraryPermissionManager: mockManager)

    XCTAssertFalse(viewModel.showLoadingIndicator)
  }

  // MARK: - Save Photo Permissions Tests

  func testCapturePhoto_WhenAuthorized_DoesNotSetDeniedError() async {
    // Given
    let mockManager = ViewfinderMockPermissionManager()
    mockManager.requestResult = .authorized

    // Use an engine with a mock session to prevent crash on capture
    let mockSession = MockCaptureSession()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = MockCaptureDevice()
    let safeEngine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)

    let viewModel = ViewfinderViewModel(
      cameraEngine: safeEngine,
      photoLibraryPermissionManager: mockManager
    )

    // When
    await viewModel.capturePhoto()

    // Then
    XCTAssertTrue(mockManager.requestAccessCalled)
    XCTAssertFalse(viewModel.isPhotoLibraryAccessDenied)
  }

  func testCapturePhoto_WhenDenied_SetsDeniedError() async {
    // Given
    let mockManager = ViewfinderMockPermissionManager()
    mockManager.requestResult = .denied
    let viewModel = ViewfinderViewModel(photoLibraryPermissionManager: mockManager)

    // When
    await viewModel.capturePhoto()

    // Then
    XCTAssertTrue(mockManager.requestAccessCalled)
    XCTAssertTrue(viewModel.isPhotoLibraryAccessDenied)
  }

  func testCapturePhoto_WhenRestricted_SetsDeniedError() async {
    // Given
    let mockManager = ViewfinderMockPermissionManager()
    mockManager.requestResult = .restricted
    let viewModel = ViewfinderViewModel(photoLibraryPermissionManager: mockManager)

    // When
    await viewModel.capturePhoto()

    // Then
    XCTAssertTrue(mockManager.requestAccessCalled)
    XCTAssertTrue(viewModel.isPhotoLibraryAccessDenied)
  }

  func testCapturePhoto_WhenLimited_DoesNotSetDeniedError() async {
    // Given
    let mockManager = ViewfinderMockPermissionManager()
    mockManager.requestResult = .limited

    // Use an engine with a mock session to prevent crash on capture
    let mockSession = MockCaptureSession()
    let mockProvider = MockCaptureDeviceProvider()
    mockProvider.mockDevice = MockCaptureDevice()
    let safeEngine = CameraEngine(captureSession: mockSession, deviceProvider: mockProvider)

    let viewModel = ViewfinderViewModel(
      cameraEngine: safeEngine,
      photoLibraryPermissionManager: mockManager
    )

    // When
    await viewModel.capturePhoto()

    // Then
    XCTAssertTrue(mockManager.requestAccessCalled)
    XCTAssertFalse(viewModel.isPhotoLibraryAccessDenied)
  }
}
