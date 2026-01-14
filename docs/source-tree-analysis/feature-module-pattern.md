# Feature Module Pattern

Each feature in `Features/` follows a consistent structure:

```
Features/
└── {FeatureName}/
    ├── {Feature}Manager.swift       # Business logic / state management
    ├── {Feature}ViewModel.swift     # View model (if MVVM)
    └── Views/
        ├── {Feature}View.swift      # Main feature view
        └── {Component}View.swift    # Sub-component views
```

## Current Features

1. **Permissions** - Handles camera and photo library permission requests
2. **Viewfinder** - Camera preview and capture engine

## Planned Features (from Epics)

- **ManualControls** - ISO, shutter speed, focus, white balance
- **VisualAids** - Histogram, focus peaking overlays
- **AssetManagement** - RAW capture, save to library

---
