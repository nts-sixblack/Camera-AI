# Application Entry

## CameraApp.swift

**Location:** `Camera/CameraApp.swift`  
**Type:** App Entry Point

The main application entry using SwiftUI's `@main` attribute.

| Component | Description |
|-----------|-------------|
| `CameraApp` | Main app struct with WindowGroup scene |

**Key Behavior:**
- Pre-warms `CameraEngine.shared` on `init()` for faster viewfinder display

---
