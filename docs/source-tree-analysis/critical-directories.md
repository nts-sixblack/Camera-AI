# Critical Directories

## 📱 Camera/ (Main Source)

The primary source code directory following a **feature-based modular architecture**.

```
Camera/
├── CameraApp.swift                  # ⭐ ENTRY POINT - App delegate equivalent
│                                    # Pre-warms CameraEngine on launch
├── ContentView.swift                # Root view (likely placeholder)
├── Assets.xcassets/                 # App icons and image assets
│   ├── AccentColor.colorset/
│   └── AppIcon.appiconset/
├── Features/                        # Feature modules (expandable)
│   ├── Permissions/                 # 🔐 Permission handling
│   │   ├── CameraPermissionManager.swift      # Camera permission logic
│   │   ├── PhotoLibraryPermissionManager.swift # Photo library permission logic
│   │   └── Views/
│   │       ├── CameraContentView.swift        # Main camera UI container
│   │       ├── PermissionDeniedView.swift     # Camera permission denied UI
│   │       └── PhotoLibraryPermissionDeniedView.swift
│   └── Viewfinder/                  # 📷 Camera preview & capture
│       ├── CameraEngine.swift       # ⭐ CORE: AVFoundation camera management
│       └── Views/
│           ├── ViewfinderContainerView.swift  # Viewfinder container
│           └── ViewfinderView.swift           # Live camera preview
└── Theme/
    └── AppColors.swift              # App color palette definitions
```

## 🧪 CameraTests/ (Unit Tests)

```
CameraTests/
├── CameraTests.swift                # Basic app tests
├── CameraEngineTests.swift          # Camera engine unit tests
├── CameraPerformanceTests.swift     # Performance benchmarks
├── CameraPermissionManagerTests.swift    # Permission manager tests
├── PhotoLibraryPermissionManagerTests.swift
├── ViewfinderViewModelTests.swift   # ViewModel tests
└── ViewfinderViewTests.swift        # View snapshot/behavior tests
```

## 🧪 CameraUITests/ (UI Tests)

```
CameraUITests/
├── CameraUITests.swift              # UI automation tests
└── CameraUITestsLaunchTests.swift   # Launch performance tests
```

## 📄 _bmad-output/ (Planning & Implementation)

```
_bmad-output/
├── planning-artifacts/              # 📋 Product planning documents
│   ├── index.md                     # Document index
│   ├── prd.md                       # Product Requirements Document
│   ├── architecture.md              # Architecture decisions
│   ├── ux-design-specification.md   # UX/UI specification
│   └── epics.md                     # User stories and epics
└── implementation-artifacts/        # 🚀 Implementation tracking
    ├── sprint-status.yaml           # Current sprint status
    └── 1-1-camera-permission-*.md   # Story implementation files
```

---
