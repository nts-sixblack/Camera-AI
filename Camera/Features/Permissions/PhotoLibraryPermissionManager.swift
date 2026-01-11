//
//  PhotoLibraryPermissionManager.swift
//  Camera
//
//  Manages Photo Library permission state and access requests for saving photos
//

import Photos

/// Represents the current Photo Library authorization state
enum PhotoLibraryAuthorizationState: Equatable, Sendable {
  case notDetermined
  case authorized
  case limited
  case denied
  case restricted
}

/// Protocol for Photo Library permission management, enabling testability
protocol PhotoLibraryPermissionManaging: Sendable {
  func checkAuthorizationStatus() -> PhotoLibraryAuthorizationState
  func requestAccess() async -> PhotoLibraryAuthorizationState
}

/// Wrapper protocol for PHPhotoLibrary static methods to enable testing
protocol PhotoLibraryAuthorizing: Sendable {
  func authorizationStatus(for accessLevel: PHAccessLevel) -> PHAuthorizationStatus
  func requestAuthorization(for accessLevel: PHAccessLevel) async -> PHAuthorizationStatus
}

/// Default implementation using actual PHPhotoLibrary
final class ProductionPhotoLibraryAuthorizer: PhotoLibraryAuthorizing, Sendable {
  func authorizationStatus(for accessLevel: PHAccessLevel) -> PHAuthorizationStatus {
    PHPhotoLibrary.authorizationStatus(for: accessLevel)
  }

  func requestAuthorization(for accessLevel: PHAccessLevel) async -> PHAuthorizationStatus {
    await PHPhotoLibrary.requestAuthorization(for: accessLevel)
  }
}

/// Manages Photo Library permissions using Photos framework APIs
/// Uses .addOnly access level to minimize requested permissions (privacy-first approach)
final class PhotoLibraryPermissionManager: PhotoLibraryPermissionManaging, Sendable {

  private let libraryAuthorizer: any PhotoLibraryAuthorizing

  init(libraryAuthorizer: any PhotoLibraryAuthorizing = ProductionPhotoLibraryAuthorizer()) {
    self.libraryAuthorizer = libraryAuthorizer
  }

  /// Checks the current Photo Library authorization status for add-only access
  /// - Returns: The current authorization state
  func checkAuthorizationStatus() -> PhotoLibraryAuthorizationState {
    let status = libraryAuthorizer.authorizationStatus(for: .addOnly)
    return mapAuthorizationStatus(status)
  }

  /// Requests Photo Library add-only access from the user
  /// - Returns: The resulting authorization state after the request
  func requestAccess() async -> PhotoLibraryAuthorizationState {
    let status = await libraryAuthorizer.requestAuthorization(for: .addOnly)
    return mapAuthorizationStatus(status)
  }

  /// Maps PHAuthorizationStatus to our domain type
  /// - Note: The @unknown default case maps to .denied as a safe fallback for future
  ///   PHAuthorizationStatus values Apple may add. This ensures the app fails closed
  ///   (requiring explicit permission) rather than fails open.
  private func mapAuthorizationStatus(_ status: PHAuthorizationStatus) -> PhotoLibraryAuthorizationState {
    switch status {
    case .notDetermined:
      return .notDetermined
    case .authorized:
      return .authorized
    case .limited:
      return .limited
    case .denied:
      return .denied
    case .restricted:
      return .restricted
    @unknown default:
      // Future-proofing: treat unknown states as denied (fail closed)
      return .denied
    }
  }
}
