# Feature: Viewfinder

**Location:** `Camera/Features/Viewfinder/`

## Views

| Component | File | Description |
|-----------|------|-------------|
| `ViewfinderContainerView` | Views/ViewfinderContainerView.swift | Container for camera preview and overlays |
| `ViewfinderView` | Views/ViewfinderView.swift | UIViewRepresentable wrapping AVCaptureVideoPreviewLayer |

## Core Engine

| Component | File | Description |
|-----------|------|-------------|
| `CameraEngine` | CameraEngine.swift | Singleton managing AVCaptureSession lifecycle |

## Component Details

### CameraEngine

The core camera service (singleton pattern):

```swift
class CameraEngine {
    static let shared: CameraEngine
    
    // Lifecycle
    func preWarm()           // Pre-initialize camera session
    func startSession()      // Begin capturing
    func stopSession()       // Stop capturing
    
    // Capture
    func capturePhoto()      // Trigger photo capture
    
    // Preview
    var previewLayer: AVCaptureVideoPreviewLayer
}
```

### ViewfinderView

A `UIViewRepresentable` that bridges UIKit's `AVCaptureVideoPreviewLayer` to SwiftUI:

```
┌─────────────────────────────────────┐
│         ViewfinderView              │
│  (UIViewRepresentable)              │
├─────────────────────────────────────┤
│  ┌───────────────────────────────┐  │
│  │  AVCaptureVideoPreviewLayer   │  │
│  │  (Live camera feed)           │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

---
