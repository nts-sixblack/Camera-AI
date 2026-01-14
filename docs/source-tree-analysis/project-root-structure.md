# Project Root Structure

```
Camera/                              # Project Root
├── .agent/                          # Agent workflows and configurations
├── .claude/                         # Claude AI integration configs
├── .git/                            # Git version control
├── _bmad/                           # BMAD framework installation
│   ├── bmb/                         # BMB agents and workflows
│   ├── bmm/                         # BMM module (main workflows)
│   └── core/                        # Core BMAD components
├── _bmad-output/                    # Generated planning & implementation docs
│   ├── planning-artifacts/          # PRD, Architecture, UX, Epics
│   └── implementation-artifacts/    # Sprint status, story files
├── Camera/                          # 📱 Main iOS App Source
│   ├── Assets.xcassets/             # App assets (icons, images)
│   ├── CameraApp.swift              # ⭐ App entry point (@main)
│   ├── ContentView.swift            # Root content view
│   ├── Features/                    # Feature modules
│   │   ├── Permissions/             # Permission handling feature
│   │   └── Viewfinder/              # Camera viewfinder feature
│   └── Theme/                       # Shared theming
│       └── AppColors.swift          # Color definitions
├── Camera.xcodeproj/                # Xcode project configuration
├── CameraTests/                     # 🧪 Unit tests
└── CameraUITests/                   # 🧪 UI tests
```

---
