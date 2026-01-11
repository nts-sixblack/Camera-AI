//
//  ViewfinderView.swift
//  Camera
//
//  SwiftUI wrapper for AVCaptureVideoPreviewLayer using UIViewRepresentable.
//  Displays the live camera preview with edge-to-edge filling.
//

import AVFoundation
import SwiftUI

/// SwiftUI view that displays the camera preview using AVCaptureVideoPreviewLayer
struct ViewfinderView: UIViewRepresentable {

  let cameraEngine: CameraEngine

  func makeUIView(context: Context) -> PreviewView {
    let view = PreviewView()
    view.previewLayer.session = cameraEngine.session
    view.previewLayer.videoGravity = .resizeAspectFill
    context.coordinator.previewLayer = view.previewLayer
    return view
  }

  func updateUIView(_ uiView: PreviewView, context: Context) {
    // Update video orientation if needed
    context.coordinator.updateVideoOrientation(UIDevice.current.orientation)
  }

  func makeCoordinator() -> ViewfinderCoordinator {
    ViewfinderCoordinator()
  }
}

/// UIView subclass that hosts the AVCaptureVideoPreviewLayer
final class PreviewView: UIView {

  override class var layerClass: AnyClass {
    AVCaptureVideoPreviewLayer.self
  }

  var previewLayer: AVCaptureVideoPreviewLayer {
    layer as! AVCaptureVideoPreviewLayer
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .black
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    backgroundColor = .black
  }
}

/// Coordinator that manages the preview layer and handles orientation changes
final class ViewfinderCoordinator: NSObject {

  /// The preview layer managed by this coordinator (set by the view)
  var previewLayer: AVCaptureVideoPreviewLayer!

  override init() {
    super.init()
  }

  /// Updates the video rotation angle based on device orientation
  func updateVideoOrientation(_ orientation: UIDeviceOrientation) {
    guard let connection = previewLayer.connection,
          connection.isVideoRotationAngleSupported(rotationAngle(for: orientation))
    else {
      return
    }

    connection.videoRotationAngle = rotationAngle(for: orientation)
  }

  private func rotationAngle(for orientation: UIDeviceOrientation) -> CGFloat {
    switch orientation {
    case .portrait:
      return 90
    case .portraitUpsideDown:
      return 270
    case .landscapeLeft:
      return 0
    case .landscapeRight:
      return 180
    default:
      return 90  // Default to portrait
    }
  }
}

#Preview {
  ZStack {
    Color.black
      .ignoresSafeArea()
    Text("Camera Preview")
      .foregroundStyle(.white.opacity(0.5))
  }
}
