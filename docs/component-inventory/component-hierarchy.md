# Component Hierarchy

```
CameraApp
└── WindowGroup
    └── CameraContentView
        ├── [if authorized]
        │   └── ViewfinderContainerView
        │       └── ViewfinderView (AVCaptureVideoPreviewLayer)
        ├── [if camera denied]
        │   └── PermissionDeniedView
        └── [if photo library denied]
            └── PhotoLibraryPermissionDeniedView
```

---
