# Data Flow

## Permission Request Flow

```
┌─────────────────┐     ┌──────────────────────┐     ┌─────────────────┐
│  App Launch     │ ──▶ │ CameraContentView    │ ──▶ │ Permission      │
│                 │     │ checks permission    │     │ Request Dialog  │
└─────────────────┘     └──────────────────────┘     └─────────────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    ▼                              ▼
          ┌─────────────────┐           ┌──────────────────────┐
          │ Authorized      │           │ Denied/Restricted    │
          │ → Show Viewfinder│          │ → Show Denied View   │
          └─────────────────┘           └──────────────────────┘
```

## Camera Capture Flow

```
User Tap Capture → CameraEngine.capturePhoto() → AVCapturePhotoOutput
                        │
                        ▼
              Process Photo Data
                        │
                        ▼
              PHPhotoLibrary.save()
                        │
                        ▼
              Update UI (success/error)
```

---
