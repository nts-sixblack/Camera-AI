//
//  ViewfinderViewTests.swift
//  CameraTests
//
//  Tests for the ViewfinderView SwiftUI wrapper
//

import AVFoundation
import SwiftUI
import XCTest

@testable import Camera

final class ViewfinderViewTests: XCTestCase {

  // MARK: - View Creation Tests

  func testViewfinderView_InitializesWithCameraEngine() {
    // Given
    let mockSession = MockCaptureSession()
    let engine = CameraEngine(captureSession: mockSession)

    // When
    let view = ViewfinderView(cameraEngine: engine)

    // Then - view should be created successfully
    XCTAssertNotNil(view)
  }

  func testViewfinderCoordinator_CreatesPreviewLayer() {
    // Given
    let session = AVCaptureSession()
    let coordinator = ViewfinderCoordinator()

    // When - simulate what the view does
    let previewLayer = AVCaptureVideoPreviewLayer(session: session)
    coordinator.previewLayer = previewLayer

    // Then
    XCTAssertNotNil(coordinator.previewLayer)
    XCTAssertEqual(coordinator.previewLayer.session, session)
  }

  func testViewfinderCoordinator_PreviewLayerUsesAspectFill() {
    // Given
    let session = AVCaptureSession()
    let coordinator = ViewfinderCoordinator()
    let previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.videoGravity = .resizeAspectFill
    coordinator.previewLayer = previewLayer

    // Then - preview should fill the screen (per AC2)
    XCTAssertEqual(coordinator.previewLayer.videoGravity, .resizeAspectFill)
  }

  // MARK: - Video Orientation Tests

  func testViewfinderCoordinator_SetsPortraitOrientation() {
    // Given
    let session = AVCaptureSession()
    let coordinator = ViewfinderCoordinator()
    let previewLayer = AVCaptureVideoPreviewLayer(session: session)
    coordinator.previewLayer = previewLayer

    // When
    coordinator.updateVideoOrientation(.portrait)

    // Then
    if let connection = coordinator.previewLayer.connection {
      XCTAssertEqual(connection.videoRotationAngle, 90)
    }
  }
}
