//
//  CameraPermissionManager.swift
//  Camera
//
//  Manages camera permission state and access requests
//

import AVFoundation

/// Represents the current camera authorization state
enum CameraAuthorizationState: Equatable, Sendable {
  case notDetermined
  case authorized
  case denied
  case restricted
}

/// Protocol for camera permission management, enabling testability
protocol CameraPermissionManaging: Sendable {
  func checkAuthorizationStatus() -> CameraAuthorizationState
  func requestAccess() async -> Bool
}

/// Wrapper protocol for AVCaptureDevice static methods to enable testing
protocol CaptureDeviceAuthorizing: Sendable {
  func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus
  func requestAccess(for mediaType: AVMediaType) async -> Bool
}

/// Default implementation using actual AVCaptureDevice
final class ProductionCaptureDeviceAuthorizer: CaptureDeviceAuthorizing, Sendable {
  func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus {
    AVCaptureDevice.authorizationStatus(for: mediaType)
  }

  func requestAccess(for mediaType: AVMediaType) async -> Bool {
    await AVCaptureDevice.requestAccess(for: mediaType)
  }
}

/// Manages camera permissions using AVFoundation APIs
final class CameraPermissionManager: CameraPermissionManaging, Sendable {

  private let deviceAuthorizer: any CaptureDeviceAuthorizing

  init(deviceAuthorizer: any CaptureDeviceAuthorizing = ProductionCaptureDeviceAuthorizer()) {
    self.deviceAuthorizer = deviceAuthorizer
  }

  /// Checks the current camera authorization status
  /// - Returns: The current authorization state
  func checkAuthorizationStatus() -> CameraAuthorizationState {
    let status = deviceAuthorizer.authorizationStatus(for: .video)
    return mapAuthorizationStatus(status)
  }

  /// Requests camera access from the user
  /// - Returns: true if access was granted, false otherwise
  func requestAccess() async -> Bool {
    await deviceAuthorizer.requestAccess(for: .video)
  }

  /// Maps AVAuthorizationStatus to our domain type
  private func mapAuthorizationStatus(_ status: AVAuthorizationStatus) -> CameraAuthorizationState {
    switch status {
    case .notDetermined:
      return .notDetermined
    case .authorized:
      return .authorized
    case .denied:
      return .denied
    case .restricted:
      return .restricted
    @unknown default:
      return .denied
    }
  }
}
