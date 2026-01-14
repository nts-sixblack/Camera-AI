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
  var onTap: ((CGPoint) -> Void)?

  func makeUIView(context: Context) -> PreviewView {
    let view = PreviewView()
    view.previewLayer.session = cameraEngine.session
    view.previewLayer.videoGravity = .resizeAspectFill
    context.coordinator.previewLayer = view.previewLayer

    // Add Tap Gesture
    let tapGesture = UITapGestureRecognizer(
      target: context.coordinator, action: #selector(ViewfinderCoordinator.handleTap(_:)))
    view.addGestureRecognizer(tapGesture)

    return view
  }

  func updateUIView(_ uiView: PreviewView, context: Context) {
    // Update video orientation if needed
    context.coordinator.updateVideoOrientation(UIDevice.current.orientation)
    context.coordinator.parent = self
  }

  func makeCoordinator() -> ViewfinderCoordinator {
    ViewfinderCoordinator(parent: self)
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
    isUserInteractionEnabled = true
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    backgroundColor = .black
    isUserInteractionEnabled = true
  }
}

/// Coordinator that manages the preview layer and handles orientation changes
final class ViewfinderCoordinator: NSObject {

  var parent: ViewfinderView

  /// The preview layer managed by this coordinator (set by the view)
  var previewLayer: AVCaptureVideoPreviewLayer!

  init(parent: ViewfinderView) {
    self.parent = parent
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

  @objc func handleTap(_ gesture: UITapGestureRecognizer) {
    guard let previewLayer = previewLayer else { return }
    let point = gesture.location(in: gesture.view)

    // Convert UI point to Device point (0-1)
    let devicePoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)

    // Trigger focus on engine
    parent.cameraEngine.focus(at: devicePoint)

    // Notify parent for UI feedback (using UI coordinates)
    parent.onTap?(point)
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
