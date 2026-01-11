//
//  ViewfinderContainerView.swift
//  Camera
//
//  Container view that manages CameraEngine lifecycle and displays ViewfinderView.
//  Shows a loading indicator if initialization takes > 100ms.
//

import Combine
import SwiftUI
import UIKit

/// Container view for the camera viewfinder with loading state management
struct ViewfinderContainerView: View {

  let photoLibraryState: PhotoLibraryAuthorizationState

  @StateObject private var viewModel = ViewfinderViewModel()

  var body: some View {
    ZStack {
      Color.black
        .ignoresSafeArea()

      switch viewModel.state {
      case .idle, .loading:
        loadingView
      case .ready:
        ViewfinderView(cameraEngine: viewModel.cameraEngine)
          .ignoresSafeArea()
      case .error(let message):
        errorView(message: message)
      }

      // Limited photo library access indicator
      if photoLibraryState == .limited {
        VStack {
          Spacer()
          Text("Photo Library: Limited Access")
            .font(.caption)
            .foregroundStyle(.orange.opacity(0.8))
            .padding(.bottom, 100)
        }
      }
    }
    .task {
      await viewModel.startCamera()
    }
    .onReceive(
      NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
    ) { _ in
      Task {
        await viewModel.resumeFromBackground()
      }
    }
    .onReceive(
      NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
    ) { _ in
      Task {
        await viewModel.pauseForBackground()
      }
    }
  }

  private var loadingView: some View {
    VStack(spacing: 16) {
      ProgressView()
        .tint(.white)
        .scaleEffect(1.5)

      if viewModel.showLoadingIndicator {
        Text("Starting camera...")
          .font(.caption)
          .foregroundStyle(.white.opacity(0.5))
      }
    }
  }

  private func errorView(message: String) -> some View {
    VStack(spacing: 16) {
      Image(systemName: "exclamationmark.triangle")
        .font(.system(size: 48))
        .foregroundStyle(.orange)

      Text("Camera Error")
        .font(.headline)
        .foregroundStyle(.white)

      Text(message)
        .font(.caption)
        .foregroundStyle(.white.opacity(0.7))
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }
  }
}

/// View state for the viewfinder container
/// Note: This is intentionally separate from CameraEngineState because:
/// 1. The view needs a `.loading` state for UI feedback (engine doesn't track this)
/// 2. The view maintains `.ready` during background to enable quick resume
/// 3. The view abstracts engine complexity from the UI layer
enum ViewfinderViewState: Equatable {
  case idle
  case loading
  case ready
  case error(String)
}

/// ViewModel for managing CameraEngine lifecycle
@MainActor
final class ViewfinderViewModel: ObservableObject {

  @Published private(set) var state: ViewfinderViewState = .idle
  @Published private(set) var showLoadingIndicator = false

  /// Uses the shared CameraEngine instance for faster initialization
  let cameraEngine = CameraEngine.shared

  private var loadingTimerTask: Task<Void, Never>?

  func startCamera() async {
    state = .loading

    // Start a timer to show loading indicator after 100ms
    loadingTimerTask = Task {
      try? await Task.sleep(nanoseconds: 100_000_000)  // 100ms
      if !Task.isCancelled {
        showLoadingIndicator = true
      }
    }

    await cameraEngine.startSession()

    // Cancel the loading timer
    loadingTimerTask?.cancel()

    // Check if session started successfully
    if cameraEngine.state == .running {
      state = .ready
    } else if case .error(let message) = cameraEngine.state {
      state = .error(message)
    } else {
      state = .ready  // Default to ready for other states
    }
  }

  func stopCamera() async {
    await cameraEngine.stopSession()
    state = .idle
  }

  /// Pauses the camera when app enters background (saves power)
  func pauseForBackground() async {
    guard state == .ready else { return }
    await cameraEngine.stopSession()
    // Don't change state - we want to resume to ready state
  }

  /// Resumes the camera when app returns to foreground
  /// Target: resume within 500ms per AC3
  func resumeFromBackground() async {
    guard state == .ready else { return }
    await cameraEngine.startSession()
  }
}

#Preview("Loading") {
  ViewfinderContainerView(photoLibraryState: .authorized)
}

#Preview("Limited Access") {
  ViewfinderContainerView(photoLibraryState: .limited)
}
