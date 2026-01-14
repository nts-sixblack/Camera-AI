# Feature: Permissions

**Location:** `Camera/Features/Permissions/`

## Views

| Component | File | Description |
|-----------|------|-------------|
| `CameraContentView` | Views/CameraContentView.swift | Root view that routes based on permission state |
| `PermissionDeniedView` | Views/PermissionDeniedView.swift | UI shown when camera permission is denied |
| `PhotoLibraryPermissionDeniedView` | Views/PhotoLibraryPermissionDeniedView.swift | UI shown when photo library permission is denied |

## Managers

| Component | File | Description |
|-----------|------|-------------|
| `CameraPermissionManager` | CameraPermissionManager.swift | Handles AVCaptureDevice camera authorization |
| `PhotoLibraryPermissionManager` | PhotoLibraryPermissionManager.swift | Handles PHPhotoLibrary authorization |

## Component Details

### CameraContentView

The primary container view that orchestrates permission flow:

```
┌─────────────────────────────────────┐
│         CameraContentView           │
├─────────────────────────────────────┤
│  if cameraAuthorized {              │
│    → ViewfinderContainerView        │
│  } else if denied {                 │
│    → PermissionDeniedView           │
│  } else {                           │
│    → Request permission prompt      │
│  }                                  │
└─────────────────────────────────────┘
```

### PermissionDeniedView

Displays when camera access is denied with:
- Explanatory text
- Button to open Settings app

### PhotoLibraryPermissionDeniedView

Displays when photo library access is denied with:
- Explanatory text
- Button to open Settings app

---
