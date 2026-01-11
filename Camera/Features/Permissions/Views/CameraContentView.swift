//
//  CameraContentView.swift
//  Camera
//
//  Main content view that handles camera and photo library permission flow and routes to appropriate views
//

import SwiftUI
import UIKit

/// Represents which permission is currently blocking the user
enum PermissionBlocker: Equatable {
  case none
  case camera(CameraAuthorizationState)
  case photoLibrary(PhotoLibraryAuthorizationState)
}

/// Main view that manages camera and photo library permission states and displays appropriate content
struct CameraContentView: View {
  @State private var cameraPermissionState: CameraAuthorizationState = .notDetermined
  @State private var photoLibraryPermissionState: PhotoLibraryAuthorizationState = .notDetermined
  @State private var isCheckingPermissions = true

  private let cameraPermissionManager: any CameraPermissionManaging
  private let photoLibraryPermissionManager: any PhotoLibraryPermissionManaging

  init(
    cameraPermissionManager: any CameraPermissionManaging = CameraPermissionManager(),
    photoLibraryPermissionManager: any PhotoLibraryPermissionManaging = PhotoLibraryPermissionManager()
  ) {
    self.cameraPermissionManager = cameraPermissionManager
    self.photoLibraryPermissionManager = photoLibraryPermissionManager
  }

  var body: some View {
    ZStack {
      Color.black
        .ignoresSafeArea()

      if isCheckingPermissions {
        ProgressView()
          .tint(.white)
      } else {
        contentForPermissionState
      }
    }
    .task {
      await checkAndRequestPermissions()
    }
    .onReceive(
      NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
    ) { _ in
      refreshPermissionStatus()
    }
    .onChange(of: cameraPermissionState) { oldValue, newValue in
      announceCameraPermissionStateChange(from: oldValue, to: newValue)
    }
    .onChange(of: photoLibraryPermissionState) { oldValue, newValue in
      announcePhotoLibraryPermissionStateChange(from: oldValue, to: newValue)
    }
  }

  /// Determines the current permission blocker state
  private var currentBlocker: PermissionBlocker {
    // Camera permission takes priority - can't capture without it
    switch cameraPermissionState {
    case .denied, .restricted:
      return .camera(cameraPermissionState)
    case .notDetermined:
      return .camera(.notDetermined)
    case .authorized:
      break
    }

    // Photo library permission - denied/restricted blocks saving but capture still possible
    switch photoLibraryPermissionState {
    case .denied, .restricted:
      return .photoLibrary(photoLibraryPermissionState)
    case .notDetermined, .authorized, .limited:
      // Limited access still allows saving new photos
      return .none
    }
  }

  @ViewBuilder
  private var contentForPermissionState: some View {
    switch currentBlocker {
    case .none:
      ViewfinderContainerView(photoLibraryState: photoLibraryPermissionState)
    case .camera(let state):
      switch state {
      case .denied:
        PermissionDeniedView(isRestricted: false, onOpenSettings: openSettings)
      case .restricted:
        PermissionDeniedView(isRestricted: true, onOpenSettings: {})
      case .notDetermined, .authorized:
        ProgressView()
          .tint(.white)
      }
    case .photoLibrary(let state):
      switch state {
      case .denied:
        PhotoLibraryPermissionDeniedView(isRestricted: false, onOpenSettings: openSettings)
      case .restricted:
        PhotoLibraryPermissionDeniedView(isRestricted: true, onOpenSettings: {})
      case .notDetermined, .authorized, .limited:
        ProgressView()
          .tint(.white)
      }
    }
  }

  /// Announces camera permission state changes for VoiceOver users
  private func announceCameraPermissionStateChange(from oldState: CameraAuthorizationState, to newState: CameraAuthorizationState) {
    guard oldState != newState else { return }

    let announcement: String
    switch newState {
    case .authorized:
      announcement = "Camera access granted. Camera is ready."
    case .denied:
      announcement = "Camera access denied. Open Settings to enable camera access."
    case .restricted:
      announcement = "Camera access is restricted by device policy."
    case .notDetermined:
      return
    }

    UIAccessibility.post(notification: .announcement, argument: announcement)
  }

  /// Announces photo library permission state changes for VoiceOver users
  private func announcePhotoLibraryPermissionStateChange(from oldState: PhotoLibraryAuthorizationState, to newState: PhotoLibraryAuthorizationState) {
    guard oldState != newState else { return }

    let announcement: String
    switch newState {
    case .authorized, .limited:
      announcement = "Photo library access granted. Photos can be saved."
    case .denied:
      announcement = "Photo library access denied. Open Settings to enable saving photos."
    case .restricted:
      announcement = "Photo library access is restricted by device policy."
    case .notDetermined:
      return
    }

    UIAccessibility.post(notification: .announcement, argument: announcement)
  }

  private func checkAndRequestPermissions() async {
    // Check camera permission first
    let cameraStatus = cameraPermissionManager.checkAuthorizationStatus()

    if cameraStatus == .notDetermined {
      let granted = await cameraPermissionManager.requestAccess()
      await MainActor.run {
        cameraPermissionState = granted ? .authorized : .denied
      }
    } else {
      await MainActor.run {
        cameraPermissionState = cameraStatus
      }
    }

    // Only proceed to photo library permission if camera is authorized
    guard cameraPermissionState == .authorized else {
      await MainActor.run {
        isCheckingPermissions = false
      }
      return
    }

    // Check photo library permission
    let photoStatus = photoLibraryPermissionManager.checkAuthorizationStatus()

    if photoStatus == .notDetermined {
      let resultState = await photoLibraryPermissionManager.requestAccess()
      await MainActor.run {
        photoLibraryPermissionState = resultState
        isCheckingPermissions = false
      }
    } else {
      await MainActor.run {
        photoLibraryPermissionState = photoStatus
        isCheckingPermissions = false
      }
    }
  }

  private func refreshPermissionStatus() {
    let cameraStatus = cameraPermissionManager.checkAuthorizationStatus()
    let photoStatus = photoLibraryPermissionManager.checkAuthorizationStatus()
    Task { @MainActor in
      cameraPermissionState = cameraStatus
      photoLibraryPermissionState = photoStatus
      isCheckingPermissions = false
    }
  }

  private func openSettings() {
    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(settingsURL)
  }
}

#Preview("Default") {
  CameraContentView()
}

#Preview("Camera Authorized, Photo Library Authorized") {
  CameraContentView(
    cameraPermissionManager: PreviewCameraPermissionManager(state: .authorized),
    photoLibraryPermissionManager: PreviewPhotoLibraryPermissionManager(state: .authorized)
  )
}

#Preview("Camera Authorized, Photo Library Limited") {
  CameraContentView(
    cameraPermissionManager: PreviewCameraPermissionManager(state: .authorized),
    photoLibraryPermissionManager: PreviewPhotoLibraryPermissionManager(state: .limited)
  )
}

#Preview("Camera Authorized, Photo Library Denied") {
  CameraContentView(
    cameraPermissionManager: PreviewCameraPermissionManager(state: .authorized),
    photoLibraryPermissionManager: PreviewPhotoLibraryPermissionManager(state: .denied)
  )
}

#Preview("Camera Denied") {
  CameraContentView(
    cameraPermissionManager: PreviewCameraPermissionManager(state: .denied),
    photoLibraryPermissionManager: PreviewPhotoLibraryPermissionManager(state: .notDetermined)
  )
}

#Preview("Camera Restricted") {
  CameraContentView(
    cameraPermissionManager: PreviewCameraPermissionManager(state: .restricted),
    photoLibraryPermissionManager: PreviewPhotoLibraryPermissionManager(state: .notDetermined)
  )
}

/// Mock camera permission manager for SwiftUI previews
private final class PreviewCameraPermissionManager: CameraPermissionManaging, @unchecked Sendable {
  private let state: CameraAuthorizationState

  init(state: CameraAuthorizationState) {
    self.state = state
  }

  func checkAuthorizationStatus() -> CameraAuthorizationState {
    state
  }

  func requestAccess() async -> Bool {
    state == .authorized
  }
}

/// Mock photo library permission manager for SwiftUI previews
private final class PreviewPhotoLibraryPermissionManager: PhotoLibraryPermissionManaging, @unchecked Sendable {
  private let state: PhotoLibraryAuthorizationState

  init(state: PhotoLibraryAuthorizationState) {
    self.state = state
  }

  func checkAuthorizationStatus() -> PhotoLibraryAuthorizationState {
    state
  }

  func requestAccess() async -> PhotoLibraryAuthorizationState {
    state
  }
}
