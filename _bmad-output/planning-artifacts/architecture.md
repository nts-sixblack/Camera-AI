---
stepsCompleted: [1, 2]
inputDocuments:
  - /Users/sixblack/code/Camera/_bmad-output/planning-artifacts/prd.md
  - /Users/sixblack/code/Camera/_bmad-output/planning-artifacts/ux-design-specification.md
  - /Users/sixblack/code/Camera/_bmad-output/planning-artifacts/index.md
workflowType: 'architecture'
project_name: 'Camera'
user_name: 'Sixblack'
date: '2026-01-08'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:**
- Manual capture controls: ISO, shutter speed, focus distance, white balance (presets + Kelvin), and lens switching.
- Capture modes and aids: Auto/Pro toggle with instant reset to auto, tap-to-focus, AE/AF lock, always-visible exposure values.
- Visual overlays: real-time RGB histogram and focus peaking toggles.
- Asset management: RAW (DNG), HEIC/JPG capture, save to Photo Library, optional geotagging.
- App state: persist last shooting mode, request/handle permissions with Settings guidance.

**Non-Functional Requirements:**
- Performance: <1.5s cold launch to capture-ready, 60 FPS dial interactions, <50ms viewfinder latency, RAW burst 10 FPS for 3s without drops.
- Reliability: >99.5% crash-free sessions, proactive thermal throttling, strict memory management for large buffers.
- Privacy/Security: offline-first, no data collection, correct handling of limited photo access.

**Scale & Complexity:**
- Primary domain: native iOS camera app with real-time imaging pipeline.
- Complexity level: high.
- Estimated architectural components: capture pipeline, UI/HUD, manual controls engine, image processing/overlays, asset persistence, permissions, device capability management.

### Technical Constraints & Dependencies
- Swift 6.x, SwiftUI + UIKit, AVFoundation, Metal, PhotoKit.
- iOS 17 minimum; iPhone-only with device capability degradation.
- Offline-first, no account system.

### Cross-Cutting Concerns Identified
- Real-time performance/latency across UI + capture pipeline.
- Thermal state monitoring and graceful degradation.
- Memory pressure management for RAW buffers.
- Permission/Privacy UX flows and App Store compliance.
- UX responsiveness (haptics, overlays) and accessibility.
