# Camera - Project Documentation Index

**Generated:** 2026-01-13  
**Workflow:** document-project (Quick Scan)

---

## Project Overview

| Attribute | Value |
|-----------|-------|
| **Type** | iOS Mobile Application |
| **Primary Language** | Swift 6.x |
| **UI Framework** | SwiftUI |
| **Architecture** | MVVM + Feature-based modular |
| **Minimum iOS** | 17.0 |
| **Status** | Active Development (Epic 1 in progress) |

---

## Quick Reference

### Tech Stack
- **Language:** Swift 6.x
- **UI:** SwiftUI
- **Camera:** AVFoundation
- **Processing:** Metal
- **Storage:** PhotoKit

### Key Entry Points
| File | Purpose |
|------|---------|
| `Camera/CameraApp.swift` | App entry point |
| `Camera/Features/Viewfinder/CameraEngine.swift` | Camera session management |
| `Camera/Features/Permissions/Views/CameraContentView.swift` | Main UI container |

### Project Statistics
| Metric | Count |
|--------|-------|
| Source Files | 11 |
| Unit Tests | 7 |
| UI Tests | 2 |
| Features | 2 |

---

## Generated Documentation

### Core Documents

| Document | Description |
|----------|-------------|
| [Project Overview](./project-overview/index.md) | Executive summary, tech stack, development status |
| [Architecture](./architecture/index.md) | System design, components, data flow, performance |
| [Source Tree Analysis](./source-tree-analysis/index.md) | Directory structure, file organization |
| [Component Inventory](./component-inventory/index.md) | SwiftUI views, managers, UI patterns |
| [Development Guide](./development-guide/index.md) | Setup, build, test, contribute |

### Additional Documents _(To be generated)_

| Document | Description | Status |
|----------|-------------|--------|
| API Contracts | N/A for this project type | Not applicable |
| Data Models | N/A (no database) | Not applicable |
| Deployment Guide | App Store submission | _(To be generated)_ |

---

## Existing Planning Documentation

**Location:** `_bmad-output/planning-artifacts/`

| Document | Description |
|----------|-------------|
| [PRD](../_bmad-output/planning-artifacts/prd.md) | Product Requirements Document |
| [Architecture Decisions](../_bmad-output/planning-artifacts/architecture.md) | Planning-phase architecture |
| [UX Design Specification](../_bmad-output/planning-artifacts/ux-design-specification.md) | UI/UX patterns and flows |
| [Epics & Stories](../_bmad-output/planning-artifacts/epics.md) | User stories and acceptance criteria |

---

## Implementation Artifacts

**Location:** `_bmad-output/implementation-artifacts/`

| Artifact | Description |
|----------|-------------|
| [Sprint Status](../_bmad-output/implementation-artifacts/sprint-status.yaml) | Current sprint progress |
| Story Files | Individual story implementation details |

---

## Getting Started

### For Developers

1. **Read** [Development Guide](./development-guide.md) for setup instructions
2. **Understand** the [Architecture](./architecture.md)
3. **Review** [Component Inventory](./component-inventory.md) before adding new UI
4. **Check** [Sprint Status](../_bmad-output/implementation-artifacts/sprint-status.yaml) for current work

### For AI-Assisted Development

When using AI coding assistants with this project:

1. **Start here** - This index provides navigation to all project knowledge
2. **For features** - Reference [PRD](../_bmad-output/planning-artifacts/prd.md) for requirements
3. **For implementation** - Check story files in `implementation-artifacts/`
4. **For patterns** - Review [Component Inventory](./component-inventory.md) for UI conventions

### Common AI Prompts

```
"Add a new feature following the pattern in Camera/Features/"
"Implement story 1-1 from sprint-status.yaml"
"Add a new dial control similar to existing components"
```

---

## Workflow Navigation

### Current Status
- **Epic 1** - Core Camera Foundation & Basic Capture: `in-progress`
- **Stories 1-1 through 1-7**: `ready-for-dev`

### Next Steps
1. Pick up a story from Sprint Status
2. Review story requirements in implementation-artifacts
3. Implement following project patterns
4. Test and submit for review

---

## Document Generation Metadata

| Attribute | Value |
|-----------|-------|
| **Workflow** | document-project |
| **Mode** | initial_scan |
| **Scan Level** | quick |
| **State File** | [project-scan-report.json](./project-scan-report.json) |
| **Generated** | 2026-01-13 |
