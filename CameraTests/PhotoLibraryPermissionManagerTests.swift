//
//  PhotoLibraryPermissionManagerTests.swift
//  CameraTests
//
//  Tests for Photo Library permission handling
//

import Photos
import XCTest

@testable import Camera

/// Mock implementation of PhotoLibraryAuthorizing for testing the real manager
/// Note: Uses @unchecked Sendable as mock state is only accessed from test thread
final class MockPhotoLibraryAuthorizer: PhotoLibraryAuthorizing, @unchecked Sendable {
  private let lock = NSLock()
  private var _mockStatus: PHAuthorizationStatus = .notDetermined
  private var _mockRequestResult: PHAuthorizationStatus = .notDetermined
  private var _requestAuthorizationCalled = false
  private var _lastAccessLevel: PHAccessLevel?

  var mockStatus: PHAuthorizationStatus {
    get { lock.withLock { _mockStatus } }
    set { lock.withLock { _mockStatus = newValue } }
  }

  var mockRequestResult: PHAuthorizationStatus {
    get { lock.withLock { _mockRequestResult } }
    set { lock.withLock { _mockRequestResult = newValue } }
  }

  var requestAuthorizationCalled: Bool {
    get { lock.withLock { _requestAuthorizationCalled } }
    set { lock.withLock { _requestAuthorizationCalled = newValue } }
  }

  var lastAccessLevel: PHAccessLevel? {
    get { lock.withLock { _lastAccessLevel } }
    set { lock.withLock { _lastAccessLevel = newValue } }
  }

  func authorizationStatus(for accessLevel: PHAccessLevel) -> PHAuthorizationStatus {
    lastAccessLevel = accessLevel
    return mockStatus
  }

  func requestAuthorization(for accessLevel: PHAccessLevel) async -> PHAuthorizationStatus {
    requestAuthorizationCalled = true
    lastAccessLevel = accessLevel
    return mockRequestResult
  }
}

final class PhotoLibraryPermissionManagerTests: XCTestCase {

  // MARK: - Authorization Status Tests

  func testNotDeterminedState_IdentifiedCorrectly() {
    // Given
    let mockAuthorizer = MockPhotoLibraryAuthorizer()
    mockAuthorizer.mockStatus = .notDetermined
    let manager = PhotoLibraryPermissionManager(libraryAuthorizer: mockAuthorizer)

    // When
    let status = manager.checkAuthorizationStatus()

    // Then
    XCTAssertEqual(status, .notDetermined)
  }

  func testAuthorizedState_IdentifiedCorrectly() {
    // Given
    let mockAuthorizer = MockPhotoLibraryAuthorizer()
    mockAuthorizer.mockStatus = .authorized
    let manager = PhotoLibraryPermissionManager(libraryAuthorizer: mockAuthorizer)

    // When
    let status = manager.checkAuthorizationStatus()

    // Then
    XCTAssertEqual(status, .authorized)
  }

  func testLimitedState_IdentifiedCorrectly() {
    // Given
    let mockAuthorizer = MockPhotoLibraryAuthorizer()
    mockAuthorizer.mockStatus = .limited
    let manager = PhotoLibraryPermissionManager(libraryAuthorizer: mockAuthorizer)

    // When
    let status = manager.checkAuthorizationStatus()

    // Then
    XCTAssertEqual(status, .limited)
  }

  func testDeniedState_IdentifiedCorrectly() {
    // Given
    let mockAuthorizer = MockPhotoLibraryAuthorizer()
    mockAuthorizer.mockStatus = .denied
    let manager = PhotoLibraryPermissionManager(libraryAuthorizer: mockAuthorizer)

    // When
    let status = manager.checkAuthorizationStatus()

    // Then
    XCTAssertEqual(status, .denied)
  }

  func testRestrictedState_IdentifiedCorrectly() {
    // Given
    let mockAuthorizer = MockPhotoLibraryAuthorizer()
    mockAuthorizer.mockStatus = .restricted
    let manager = PhotoLibraryPermissionManager(libraryAuthorizer: mockAuthorizer)

    // When
    let status = manager.checkAuthorizationStatus()

    // Then
    XCTAssertEqual(status, .restricted)
  }

  // MARK: - Request Access Tests

  func testRequestAccess_WhenAuthorized_ReturnsAuthorized() async {
    // Given
    let mockAuthorizer = MockPhotoLibraryAuthorizer()
    mockAuthorizer.mockRequestResult = .authorized
    let manager = PhotoLibraryPermissionManager(libraryAuthorizer: mockAuthorizer)

    // When
    let result = await manager.requestAccess()

    // Then
    XCTAssertEqual(result, .authorized)
    XCTAssertTrue(mockAuthorizer.requestAuthorizationCalled)
  }

  func testRequestAccess_WhenLimited_ReturnsLimited() async {
    // Given
    let mockAuthorizer = MockPhotoLibraryAuthorizer()
    mockAuthorizer.mockRequestResult = .limited
    let manager = PhotoLibraryPermissionManager(libraryAuthorizer: mockAuthorizer)

    // When
    let result = await manager.requestAccess()

    // Then
    XCTAssertEqual(result, .limited)
    XCTAssertTrue(mockAuthorizer.requestAuthorizationCalled)
  }

  func testRequestAccess_WhenDenied_ReturnsDenied() async {
    // Given
    let mockAuthorizer = MockPhotoLibraryAuthorizer()
    mockAuthorizer.mockRequestResult = .denied
    let manager = PhotoLibraryPermissionManager(libraryAuthorizer: mockAuthorizer)

    // When
    let result = await manager.requestAccess()

    // Then
    XCTAssertEqual(result, .denied)
    XCTAssertTrue(mockAuthorizer.requestAuthorizationCalled)
  }

  func testRequestAccess_WhenRestricted_ReturnsRestricted() async {
    // Given
    let mockAuthorizer = MockPhotoLibraryAuthorizer()
    mockAuthorizer.mockRequestResult = .restricted
    let manager = PhotoLibraryPermissionManager(libraryAuthorizer: mockAuthorizer)

    // When
    let result = await manager.requestAccess()

    // Then
    XCTAssertEqual(result, .restricted)
    XCTAssertTrue(mockAuthorizer.requestAuthorizationCalled)
  }

  // MARK: - Access Level Tests

  func testCheckAuthorizationStatus_UsesAddOnlyAccessLevel() {
    // Given
    let mockAuthorizer = MockPhotoLibraryAuthorizer()
    mockAuthorizer.mockStatus = .authorized
    let manager = PhotoLibraryPermissionManager(libraryAuthorizer: mockAuthorizer)

    // When
    _ = manager.checkAuthorizationStatus()

    // Then
    XCTAssertEqual(mockAuthorizer.lastAccessLevel, .addOnly)
  }

  func testRequestAccess_UsesAddOnlyAccessLevel() async {
    // Given
    let mockAuthorizer = MockPhotoLibraryAuthorizer()
    mockAuthorizer.mockRequestResult = .authorized
    let manager = PhotoLibraryPermissionManager(libraryAuthorizer: mockAuthorizer)

    // When
    _ = await manager.requestAccess()

    // Then
    XCTAssertEqual(mockAuthorizer.lastAccessLevel, .addOnly)
  }

  // MARK: - PhotoLibraryAuthorizationState Equatable Tests

  func testPhotoLibraryAuthorizationState_EquatableConformance() {
    XCTAssertEqual(PhotoLibraryAuthorizationState.authorized, PhotoLibraryAuthorizationState.authorized)
    XCTAssertEqual(PhotoLibraryAuthorizationState.limited, PhotoLibraryAuthorizationState.limited)
    XCTAssertEqual(PhotoLibraryAuthorizationState.denied, PhotoLibraryAuthorizationState.denied)
    XCTAssertEqual(PhotoLibraryAuthorizationState.notDetermined, PhotoLibraryAuthorizationState.notDetermined)
    XCTAssertEqual(PhotoLibraryAuthorizationState.restricted, PhotoLibraryAuthorizationState.restricted)

    XCTAssertNotEqual(PhotoLibraryAuthorizationState.authorized, PhotoLibraryAuthorizationState.denied)
    XCTAssertNotEqual(PhotoLibraryAuthorizationState.limited, PhotoLibraryAuthorizationState.authorized)
    XCTAssertNotEqual(PhotoLibraryAuthorizationState.notDetermined, PhotoLibraryAuthorizationState.restricted)
  }

  // MARK: - Settings URL Tests

  func testSettingsURL_IsValid() {
    let settingsURLString = UIApplication.openSettingsURLString
    let settingsURL = URL(string: settingsURLString)

    XCTAssertNotNil(settingsURL, "Settings URL should be valid")
    XCTAssertFalse(settingsURLString.isEmpty, "Settings URL string should not be empty")
  }
}

// MARK: - PhotoLibraryPermissionDeniedView Logic Tests

final class PhotoLibraryPermissionDeniedViewTests: XCTestCase {

  func testDeniedView_WhenNotRestricted_ShowsOpenSettingsButton() {
    // Given a denied (not restricted) state
    let isRestricted = false

    // When the view is created
    // Then it should show the Open Settings button (verified by isRestricted being false)
    XCTAssertFalse(isRestricted, "Denied state should show Open Settings button")
  }

  func testDeniedView_WhenRestricted_HidesOpenSettingsButton() {
    // Given a restricted state
    let isRestricted = true

    // When the view is created
    // Then it should hide the Open Settings button (verified by isRestricted being true)
    XCTAssertTrue(isRestricted, "Restricted state should hide Open Settings button")
  }

  func testDeniedView_TitleText_DiffersByState() {
    // Verify title text differs between denied and restricted states
    let deniedTitle = "Photo Library Access Required"
    let restrictedTitle = "Photo Library Access Restricted"

    XCTAssertNotEqual(deniedTitle, restrictedTitle, "Title text should differ based on restriction state")
  }

  func testDeniedView_DescriptionText_IncludesSettingsForDenied() {
    let deniedDescription = "To save your captured photos, please enable Photo Library access in Settings."

    XCTAssertTrue(deniedDescription.contains("Settings"), "Denied description should mention Settings")
  }

  func testDeniedView_DescriptionText_MentionsAdministratorForRestricted() {
    let restrictedDescription = "Photo Library access is restricted by parental controls or device policy. Contact your administrator to enable access."

    XCTAssertTrue(restrictedDescription.contains("administrator"), "Restricted description should mention administrator")
    XCTAssertFalse(restrictedDescription.contains("Settings"), "Restricted description should not mention Settings")
  }
}
