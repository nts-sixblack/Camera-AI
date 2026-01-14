# Component Architecture

## CameraEngine (Core Service)

**Location:** `Camera/Features/Viewfinder/CameraEngine.swift`

The central camera management service that:
- Manages `AVCaptureSession` lifecycle
- Handles camera input/output configuration
- Provides preview layer for viewfinder
- Coordinates capture requests

```swift
class CameraEngine {
    static let shared: CameraEngine
    
    func preWarm()                    // Pre-initialize on app launch
    func startSession()               // Begin camera session
    func stopSession()                // End camera session
    func capturePhoto()               // Trigger photo capture
}
```

**Design Pattern:** Singleton with shared instance for app-wide access

## Permission Managers

**Location:** `Camera/Features/Permissions/`

Dedicated managers for each permission type:

| Manager | Responsibility |
|---------|----------------|
| `CameraPermissionManager` | AVCaptureDevice authorization |
| `PhotoLibraryPermissionManager` | PHPhotoLibrary authorization |

**Key Features:**
- Observable state for SwiftUI binding
- Graceful denied state handling
- Settings app deep linking

## View Architecture

Views follow SwiftUI best practices:

```
CameraContentView                    # Root view with permission routing
├── ViewfinderContainerView          # Camera preview container
│   └── ViewfinderView               # Live camera feed (UIViewRepresentable)
├── PermissionDeniedView             # Camera permission denied state
└── PhotoLibraryPermissionDeniedView # Photo library denied state
```

---
