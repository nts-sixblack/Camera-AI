//
//  CameraPermissionManagerTests.swift
//  CameraTests
//
//  Tests for camera permission handling
//

import AVFoundation
import XCTest

@testable import Camera

/// Mock implementation of CaptureDeviceAuthorizing for testing the real manager
/// Note: Uses @unchecked Sendable as mock state is only accessed from test thread
final class MockCaptureDeviceAuthorizer: CaptureDeviceAuthorizing, @unchecked Sendable {
  private let lock = NSLock()
  private var _mockStatus: AVAuthorizationStatus = .notDetermined
  private var _mockRequestAccessResult: Bool = false
  private var _requestAccessCalled = false

  var mockStatus: AVAuthorizationStatus {
    get { lock.withLock { _mockStatus } }
    set { lock.withLock { _mockStatus = newValue } }
  }

  var mockRequestAccessResult: Bool {
    get { lock.withLock { _mockRequestAccessResult } }
    set { lock.withLock { _mockRequestAccessResult = newValue } }
  }

  var requestAccessCalled: Bool {
    get { lock.withLock { _requestAccessCalled } }
    set { lock.withLock { _requestAccessCalled = newValue } }
  }

  func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus {
    return mockStatus
  }

  func requestAccess(for mediaType: AVMediaType) async -> Bool {
    requestAccessCalled = true
    return mockRequestAccessResult
  }
}

final class CameraPermissionManagerTests: XCTestCase {

  // MARK: - Authorization Status Tests

  func testNotDeterminedState_IdentifiedCorrectly() {
    // Given
    let mockDevice = MockCaptureDeviceAuthorizer()
    mockDevice.mockStatus = .notDetermined
    let manager = CameraPermissionManager(deviceAuthorizer: mockDevice)

    // When
    let status = manager.checkAuthorizationStatus()

    // Then
    XCTAssertEqual(status, .notDetermined)
  }

  func testAuthorizedState_IdentifiedCorrectly() {
    // Given
    let mockDevice = MockCaptureDeviceAuthorizer()
    mockDevice.mockStatus = .authorized
    let manager = CameraPermissionManager(deviceAuthorizer: mockDevice)

    // When
    let status = manager.checkAuthorizationStatus()

    // Then
    XCTAssertEqual(status, .authorized)
  }

  func testDeniedState_IdentifiedCorrectly() {
    // Given
    let mockDevice = MockCaptureDeviceAuthorizer()
    mockDevice.mockStatus = .denied
    let manager = CameraPermissionManager(deviceAuthorizer: mockDevice)

    // When
    let status = manager.checkAuthorizationStatus()

    // Then
    XCTAssertEqual(status, .denied)
  }

  func testRestrictedState_IdentifiedCorrectly() {
    // Given
    let mockDevice = MockCaptureDeviceAuthorizer()
    mockDevice.mockStatus = .restricted
    let manager = CameraPermissionManager(deviceAuthorizer: mockDevice)

    // When
    let status = manager.checkAuthorizationStatus()

    // Then
    XCTAssertEqual(status, .restricted)
  }

  // MARK: - Request Access Tests

  func testRequestAccess_WhenGranted_ReturnsTrue() async {
    // Given
    let mockDevice = MockCaptureDeviceAuthorizer()
    mockDevice.mockRequestAccessResult = true
    let manager = CameraPermissionManager(deviceAuthorizer: mockDevice)

    // When
    let result = await manager.requestAccess()

    // Then
    XCTAssertTrue(result)
    XCTAssertTrue(mockDevice.requestAccessCalled)
  }

  func testRequestAccess_WhenDenied_ReturnsFalse() async {
    // Given
    let mockDevice = MockCaptureDeviceAuthorizer()
    mockDevice.mockRequestAccessResult = false
    let manager = CameraPermissionManager(deviceAuthorizer: mockDevice)

    // When
    let result = await manager.requestAccess()

    // Then
    XCTAssertFalse(result)
    XCTAssertTrue(mockDevice.requestAccessCalled)
  }

  // MARK: - Settings URL Tests

  func testSettingsURL_IsValid() {
    let settingsURLString = UIApplication.openSettingsURLString
    let settingsURL = URL(string: settingsURLString)

    XCTAssertNotNil(settingsURL, "Settings URL should be valid")
    XCTAssertFalse(settingsURLString.isEmpty, "Settings URL string should not be empty")
  }

  // MARK: - CameraAuthorizationState Equatable Tests

  func testCameraAuthorizationState_EquatableConformance() {
    XCTAssertEqual(CameraAuthorizationState.authorized, CameraAuthorizationState.authorized)
    XCTAssertEqual(CameraAuthorizationState.denied, CameraAuthorizationState.denied)
    XCTAssertEqual(CameraAuthorizationState.notDetermined, CameraAuthorizationState.notDetermined)
    XCTAssertEqual(CameraAuthorizationState.restricted, CameraAuthorizationState.restricted)

    XCTAssertNotEqual(CameraAuthorizationState.authorized, CameraAuthorizationState.denied)
    XCTAssertNotEqual(CameraAuthorizationState.notDetermined, CameraAuthorizationState.restricted)
  }
}
