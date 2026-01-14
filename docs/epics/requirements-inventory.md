# Requirements Inventory

## Functional Requirements

**Camera Capture Control:**
- FR1: User can manually adjust ISO value with immediate preview feedback.
- FR2: User can manually adjust Shutter Speed with immediate preview feedback.
- FR3: User can manually adjust Focus distance with visual confirmation.
- FR4: User can select White Balance from presets (Sunny, Cloudy, etc.) or set a custom Kelvin value.
- FR5: User can toggle "Auto" mode to instantly reset all manual parameters to automatic.
- FR6: User can switch between available hardware lenses (Ultra Wide, Wide, Telephoto).

**Viewfinder & Visual Aids:**
- FR7: User can view a real-time RGB histogram overlaid on the viewfinder.
- FR8: User can toggle "Focus Peaking" to highlight in-focus edges with a contrasting color.
- FR9: User can tap-to-focus on a specific point in the viewfinder.
- FR10: User can lock Exposure and Focus (AE/AF Lock) independently.
- FR11: User can view current exposure values (ISO, Shutter, Aperture) at all times in Pro mode.

**Asset Management:**
- FR12: User can capture images in RAW (DNG) format.
- FR13: User can capture images in HEIC or JPG format.
- FR14: System must save captured assets directly to the device's main Photo Library.
- FR15: User can toggle geotagging (Location Metadata) on or off.

**App State & Settings:**
- FR16: System must persist the last used shooting mode (Auto vs Manual) between sessions.
- FR17: System must request necessary permissions (Camera, Photo Library) with context explanations.
- FR18: System must gracefully handle denied permissions by directing user to Settings.

## NonFunctional Requirements

**Performance (CRITICAL):**
- NFR1: System must support continuous RAW capture at minimum 10 FPS for at least 3 seconds (buffer depth) without dropping frames.
- NFR2: App must be ready to capture (live preview active, buttons responsive) within 1.5 seconds of cold launch on iPhone 15 Pro.
- NFR3: Glass-to-glass viewfinder latency must remain under 50ms to prevent "swimming" effect during panning.
- NFR4: All manual dial interactions must update the preview at 60 FPS (16ms frame budget).

**Reliability:**
- NFR5: App must monitor thermal state and gracefully degrade (disable high-fps viewfinder, pause background processing) BEFORE the system terminates the app.
- NFR6: Must maintain > 99.5% crash-free sessions.
- NFR7: App must strictly adhere to iOS memory limits (specifically during high-res burst capture) to avoid OOM kills.

**Security & Privacy:**
- NFR8: App must strictly use Camera and Photo Library permissions only for capture and saving. No data is collected or transmitted.
- NFR9: App must correctly handle "Limited Access" permission state if user selects it.

## Additional Requirements

**From Architecture:**
- Swift 6.x with SwiftUI + UIKit hybrid approach
- AVFoundation for camera, Metal for image processing, PhotoKit for library management
- iOS 17.0 minimum deployment target
- iPhone-only with graceful degradation for older models (optimized for iPhone 15 Pro+)
- Offline-first architecture, no account system required
- Real-time performance across UI and capture pipeline
- Thermal state monitoring with graceful degradation
- Memory pressure management for RAW buffers
- App Store compliance with Guideline 5.1.1 (Data Privacy)

**From UX Design:**
- Swipe-based dial controls with haptic feedback for ISO, Shutter, Focus, White Balance
- Dark mode only UI with true black (#000000) background for OLED efficiency
- High contrast design for outdoor visibility
- Focus peaking visualization overlay
- Real-time RGB histogram overlay (toggleable)
- One-tap Auto/Pro mode toggle with instant transition (<500ms)
- Thumb-zone control placement (bottom 180pt of screen)
- Controls fade to 30% opacity after 3 seconds of inactivity
- Portrait-only UI orientation (viewfinder stays sensor-aligned)
- WCAG AA accessibility compliance (4.5:1 contrast ratio minimum)
- Minimum 44x44pt touch targets for all controls
- Full VoiceOver support for all controls and states
- Reduced Motion support (respect system settings)
- Device class responsive scaling (iPhone SE/mini to iPhone Max/Plus)
- Halide-style minimal design direction with edge-to-edge viewfinder

## FR Coverage Map

| FR | Epic | Description |
|----|------|-------------|
| FR1 | Epic 2 | Manual ISO adjustment with immediate preview feedback |
| FR2 | Epic 2 | Manual Shutter Speed adjustment with immediate preview feedback |
| FR3 | Epic 2 | Manual Focus distance adjustment with visual confirmation |
| FR4 | Epic 2 | White Balance presets and custom Kelvin value |
| FR5 | Epic 1 | Auto mode toggle to reset all manual parameters |
| FR6 | Epic 2 | Hardware lens switching (Ultra Wide, Wide, Telephoto) |
| FR7 | Epic 3 | Real-time RGB histogram overlay |
| FR8 | Epic 3 | Focus Peaking toggle with contrasting color highlight |
| FR9 | Epic 1 | Tap-to-focus on viewfinder |
| FR10 | Epic 3 | Independent AE/AF Lock |
| FR11 | Epic 2 | Exposure values display (ISO, Shutter, Aperture) |
| FR12 | Epic 4 | RAW (DNG) format capture |
| FR13 | Epic 1 | HEIC/JPG format capture |
| FR14 | Epic 1 | Save to device Photo Library |
| FR15 | Epic 4 | Geotagging toggle for location metadata |
| FR16 | Epic 1 | Persist last shooting mode between sessions |
| FR17 | Epic 1 | Request Camera/Photo Library permissions with context |
| FR18 | Epic 1 | Handle denied permissions with Settings redirect |
