# Architecture Overview

## Pattern
**MVVM + Feature-based modular architecture**

The application follows a feature-based modular structure where each major feature (Permissions, Viewfinder, etc.) is encapsulated with its own views, managers, and business logic.

## High-Level Components

```
┌─────────────────────────────────────────────────────────┐
│                      CameraApp                          │
│                    (Entry Point)                        │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────┐   │
│  │              Features Layer                      │   │
│  │  ┌─────────────┐  ┌─────────────────────────┐   │   │
│  │  │ Permissions │  │      Viewfinder         │   │   │
│  │  │  • Camera   │  │   • CameraEngine        │   │   │
│  │  │  • Photos   │  │   • ViewfinderView      │   │   │
│  │  └─────────────┘  └─────────────────────────┘   │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────┐   │
│  │              Shared Layer                        │   │
│  │   • AppColors (Theme)                           │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---
