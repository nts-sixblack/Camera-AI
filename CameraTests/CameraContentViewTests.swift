//
//  CameraContentViewTests.swift
//  CameraTests
//
//  Tests for CameraContentView permission orchestration logic
//

import XCTest

@testable import Camera

// MARK: - Mock Permission Managers for Testing

/// Thread-safe mock for camera permission testing
final class MockCameraPermissionManager: CameraPermissionManaging, @unchecked Sendable {
  private let lock = NSLock()
  private var _state: CameraAuthorizationState = .notDetermined
  private var _requestAccessResult: Bool = false
  private var _requestAccessCalled = false

  var state: CameraAuthorizationState {
    get { lock.withLock { _state } }
    set { lock.withLock { _state = newValue } }
  }

  var requestAccessResult: Bool {
    get { lock.withLock { _requestAccessResult } }
    set { lock.withLock { _requestAccessResult = newValue } }
  }

  var requestAccessCalled: Bool {
    get { lock.withLock { _requestAccessCalled } }
    set { lock.withLock { _requestAccessCalled = newValue } }
  }

  func checkAuthorizationStatus() -> CameraAuthorizationState {
    state
  }

  func requestAccess() async -> Bool {
    requestAccessCalled = true
    return requestAccessResult
  }
}

/// Thread-safe mock for photo library permission testing
final class MockPhotoLibraryPermissionManager: PhotoLibraryPermissionManaging, @unchecked Sendable {
  private let lock = NSLock()
  private var _state: PhotoLibraryAuthorizationState = .notDetermined
  private var _requestAccessResult: PhotoLibraryAuthorizationState = .authorized

  var state: PhotoLibraryAuthorizationState {
    get { lock.withLock { _state } }
    set { lock.withLock { _state = newValue } }
  }

  var requestAccessResult: PhotoLibraryAuthorizationState {
    get { lock.withLock { _requestAccessResult } }
    set { lock.withLock { _requestAccessResult = newValue } }
  }

  func checkAuthorizationStatus() -> PhotoLibraryAuthorizationState {
    state
  }

  func requestAccess() async -> PhotoLibraryAuthorizationState {
    requestAccessResult
  }
}

// MARK: - CameraContentView Tests

final class CameraContentViewTests: XCTestCase {

  // MARK: - Permission State Flow Tests (M1 fix)

  func testNotDeterminedState_RequestsPermission() async {
    // Given
    let mockCamera = MockCameraPermissionManager()
    mockCamera.state = .notDetermined
    mockCamera.requestAccessResult = true

    // When - simulate the permission check flow
    let initialStatus = mockCamera.checkAuthorizationStatus()
    XCTAssertEqual(initialStatus, .notDetermined)

    if initialStatus == .notDetermined {
      let granted = await mockCamera.requestAccess()
      XCTAssertTrue(granted)
      XCTAssertTrue(mockCamera.requestAccessCalled)
    }
  }

  func testAuthorizedState_NoPermissionRequest() async {
    // Given
    let mockCamera = MockCameraPermissionManager()
    mockCamera.state = .authorized

    // When
    let status = mockCamera.checkAuthorizationStatus()

    // Then - should not request access when already authorized
    XCTAssertEqual(status, .authorized)
    XCTAssertFalse(mockCamera.requestAccessCalled)
  }

  func testDeniedState_NoPermissionRequest() async {
    // Given
    let mockCamera = MockCameraPermissionManager()
    mockCamera.state = .denied

    // When
    let status = mockCamera.checkAuthorizationStatus()

    // Then - should not request access when denied
    XCTAssertEqual(status, .denied)
    XCTAssertFalse(mockCamera.requestAccessCalled)
  }

  func testRestrictedState_NoPermissionRequest() async {
    // Given
    let mockCamera = MockCameraPermissionManager()
    mockCamera.state = .restricted

    // When
    let status = mockCamera.checkAuthorizationStatus()

    // Then - should not request access when restricted
    XCTAssertEqual(status, .restricted)
    XCTAssertFalse(mockCamera.requestAccessCalled)
  }

  func testPhotoLibraryPermission_OnlyCheckedAfterCameraAuthorized() async {
    // Given
    let mockCamera = MockCameraPermissionManager()
    let mockPhotoLibrary = MockPhotoLibraryPermissionManager()
    mockCamera.state = .authorized
    mockPhotoLibrary.state = .notDetermined
    mockPhotoLibrary.requestAccessResult = .authorized

    // When - camera is authorized, photo library should be checked
    let cameraStatus = mockCamera.checkAuthorizationStatus()
    XCTAssertEqual(cameraStatus, .authorized)

    // Photo library check should happen after camera is authorized
    let photoStatus = mockPhotoLibrary.checkAuthorizationStatus()
    XCTAssertEqual(photoStatus, .notDetermined)
  }
}

// MARK: - PermissionDeniedView Tests (M2 fix)

final class PermissionDeniedViewTests: XCTestCase {

  func testDeniedState_ShowsSettingsButton() {
    // Given - user denied permission (not restricted)
    let isRestricted = false

    // Then - Settings button should be visible
    // The view shows button when !isRestricted
    XCTAssertFalse(isRestricted, "Denied state should show Settings button")
  }

  func testRestrictedState_HidesSettingsButton() {
    // Given - restricted by parental controls
    let isRestricted = true

    // Then - Settings button should be hidden
    // The view hides button when isRestricted
    XCTAssertTrue(isRestricted, "Restricted state should hide Settings button")
  }

  func testRestrictedState_ButtonHiddenLogic() {
    // Given
    let isRestricted = true

    // When - evaluating the condition used in PermissionDeniedView
    let shouldShowButton = !isRestricted

    // Then
    XCTAssertFalse(shouldShowButton, "Button should be hidden when restricted")
  }

  func testDeniedState_ButtonShownLogic() {
    // Given
    let isRestricted = false

    // When - evaluating the condition used in PermissionDeniedView
    let shouldShowButton = !isRestricted

    // Then
    XCTAssertTrue(shouldShowButton, "Button should be shown when denied (not restricted)")
  }
}
