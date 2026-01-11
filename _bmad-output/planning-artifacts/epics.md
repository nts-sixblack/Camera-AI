---
stepsCompleted: [1, 2, 3]
inputDocuments:
  - /Users/sixblack/code/Camera/_bmad-output/planning-artifacts/prd.md
  - /Users/sixblack/code/Camera/_bmad-output/planning-artifacts/architecture.md
  - /Users/sixblack/code/Camera/_bmad-output/planning-artifacts/ux-design-specification.md
---

# Camera - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for Camera, decomposing the requirements from the PRD, UX Design, and Architecture documents into implementable stories.

## Requirements Inventory

### Functional Requirements

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

### NonFunctional Requirements

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

### Additional Requirements

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

### FR Coverage Map

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

## Epic List

### Epic 1: Core Camera Foundation & Basic Capture
Users can launch the app, grant permissions, and capture photos in Auto mode with the familiar viewfinder experience. This establishes the foundation—permission handling, basic capture, tap-to-focus, and saving to Photo Library.

**FRs covered:** FR5, FR9, FR13, FR14, FR16, FR17, FR18

### Epic 2: Manual Controls & Pro Mode
Users can switch to Pro mode and manually control ISO, Shutter Speed, Focus, and White Balance with immediate visual feedback. This is the core differentiator—dial-based manual controls with lens switching and exposure value display.

**FRs covered:** FR1, FR2, FR3, FR4, FR6, FR11

### Epic 3: Visual Aids & Capture Confidence
Users can enable histogram and focus peaking overlays, and lock exposure/focus independently to confirm their shot before capture. Professional tools for verifying settings and confirming sharp focus.

**FRs covered:** FR7, FR8, FR10

### Epic 4: Advanced Capture & Asset Management
Users can capture in RAW/ProRAW formats and control geotagging for professional-grade asset management. Expands capture options with RAW support and location metadata control for power users.

**FRs covered:** FR12, FR15

## Epic 1: Core Camera Foundation & Basic Capture

Users can launch the app, grant permissions, and capture photos in Auto mode with the familiar viewfinder experience.

### Story 1.1: Camera Permission Request Flow

As a **new user**,
I want **the app to request camera access with a clear explanation of why it's needed**,
So that **I understand the purpose and can make an informed decision about granting permission**.

**Acceptance Criteria:**

**Given** the app is launched for the first time
**When** the app attempts to access the camera
**Then** a system permission dialog is presented with a custom usage description explaining the camera is needed to capture photos
**And** the dialog appears before any camera preview is shown

**Given** the user grants camera permission
**When** the permission is confirmed
**Then** the camera session initializes and displays the live viewfinder within 1.5 seconds (NFR2)

**Given** the user denies camera permission
**When** the denial is confirmed
**Then** the app displays an inline explanation screen with a "Open Settings" button
**And** tapping the button opens the iOS Settings app directly to the Camera app's permission page (FR18)

**Given** the user has previously denied permission
**When** the app is launched again
**Then** the app displays the permission-denied state with Settings redirect (no repeated system prompts)

**Technical Implementation:** Use `AVCaptureDevice.requestAccess(for: .video)` with Info.plist `NSCameraUsageDescription`. Handle `.denied`, `.restricted`, and `.notDetermined` states via `AVCaptureDevice.authorizationStatus(for:)`.

---

### Story 1.2: Photo Library Permission Request Flow

As a **user capturing photos**,
I want **the app to request Photo Library write access with a clear explanation**,
So that **my captured photos are saved to my Camera Roll**.

**Acceptance Criteria:**

**Given** the user attempts to save a captured photo for the first time
**When** Photo Library permission has not been granted
**Then** a system permission dialog is presented explaining photos will be saved to the Camera Roll

**Given** the user grants full Photo Library access
**When** the permission is confirmed
**Then** subsequent saves occur without prompts (FR14)

**Given** the user grants "Limited Access" (iOS 14+)
**When** the permission state is `.limited`
**Then** the app functions correctly for saving new photos (NFR9)
**And** a subtle indicator may inform the user of limited access state

**Given** the user denies Photo Library permission
**When** the denial is confirmed
**Then** the app displays an explanation with "Open Settings" button
**And** capture remains functional (photos can be taken but not saved)

**Technical Implementation:** Use `PHPhotoLibrary.requestAuthorization(for: .addOnly)` for write-only access. Handle `.authorized`, `.limited`, `.denied`, `.restricted` states via `PHPhotoLibrary.authorizationStatus(for:)`.

---

### Story 1.3: Viewfinder Initialization & Live Preview

As a **user**,
I want **to see a live camera preview immediately upon launching the app**,
So that **I can frame my shot and capture the moment quickly**.

**Acceptance Criteria:**

**Given** the user has granted camera permission
**When** the app is launched (cold start)
**Then** a live viewfinder preview is displayed within 1.5 seconds (NFR2)
**And** the shutter button is responsive and ready to capture

**Given** the app is in the foreground
**When** the viewfinder is active
**Then** glass-to-glass latency remains under 50ms (NFR3)
**And** no visible "swimming" effect occurs during panning

**Given** the app was backgrounded
**When** the app returns to foreground
**Then** the camera session resumes and preview displays within 500ms

**Given** iOS interrupts the camera (phone call, Siri)
**When** the interruption ends
**Then** the camera session automatically resumes

**Technical Implementation:** Use `AVCaptureSession` with `.builtInWideAngleCamera`. Configure `AVCaptureVideoPreviewLayer` with `.resizeAspectFill`. Prioritize camera initialization in `application(_:didFinishLaunchingWithOptions:)`.

---

### Story 1.4: Tap-to-Focus Interaction

As a **user**,
I want **to tap anywhere on the viewfinder to set the focus point**,
So that **I can control what part of the scene is in sharp focus**.

**Acceptance Criteria:**

**Given** the viewfinder is active in Auto mode
**When** the user taps on a point in the viewfinder
**Then** a focus indicator (square or circle) appears at the tap location
**And** the camera adjusts focus to that point
**And** the indicator animates briefly then fades (within 1.5 seconds)

**Given** the user taps on a new point
**When** focus is already set on a previous point
**Then** the focus immediately adjusts to the new tap location
**And** the previous indicator disappears

**Given** the tapped area is too dark or lacks contrast
**When** the camera cannot achieve focus lock
**Then** the focus indicator pulses or changes to indicate hunting/failure

**Technical Implementation:** Convert tap coordinates to camera coordinate space using `AVCaptureVideoPreviewLayer.captureDevicePointConverted(fromLayerPoint:)`. Set focus via `AVCaptureDevice.setFocusModeLocked(lensPosition:)` or `.autoFocus` at the specified point of interest.

---

### Story 1.5: Basic Photo Capture (HEIC/JPG)

As a **user**,
I want **to tap the shutter button to capture a photo in HEIC or JPG format**,
So that **I can preserve the moment in a standard image format**.

**Acceptance Criteria:**

**Given** the viewfinder is active and permissions are granted
**When** the user taps the shutter button
**Then** a photo is captured immediately (no perceptible delay)
**And** a brief flash animation confirms the capture
**And** haptic feedback is triggered

**Given** a photo is captured
**When** the capture completes
**Then** the image is saved to the device's Photo Library in HEIC format (default) (FR13, FR14)
**And** the capture process does not block the viewfinder

**Given** the device does not support HEIC
**When** a photo is captured
**Then** the image is saved as JPG fallback

**Technical Implementation:** Use `AVCapturePhotoOutput` with `AVCapturePhotoSettings`. Set `.photoCodecTypes` to `.hevc` (HEIC) with `.jpeg` fallback. Save via `PHPhotoLibrary.shared().performChanges` with `PHAssetCreationRequest`. Trigger haptic feedback using `UIImpactFeedbackGenerator(style: .medium)` on shutter press.

---

### Story 1.6: Auto Mode Toggle

As a **user**,
I want **a visible "Auto" button that resets all settings to automatic mode**,
So that **I can quickly return to point-and-shoot simplicity or hand my phone to someone else**.

**Acceptance Criteria:**

**Given** the app is in any mode (Auto or Pro)
**When** the user taps the "Auto" button
**Then** all manual parameters (if any were set) are reset to automatic
**And** the transition completes in under 500ms
**And** the interface displays the simplified Auto mode view (FR5)

**Given** the app is in Auto mode
**When** the app is closed and reopened
**Then** the app restores to Auto mode (FR16)

**Given** the Auto toggle is displayed
**When** viewed in any lighting condition
**Then** the button has minimum 44x44pt touch target and WCAG AA contrast

**Technical Implementation:** Reset `AVCaptureDevice` exposure/focus modes to `.continuousAutoExposure` and `.continuousAutoFocus`. Store mode preference in `UserDefaults` for persistence (FR16).

---

### Story 1.7: Mode Persistence Between Sessions

As a **returning user**,
I want **the app to remember my last shooting mode (Auto vs Pro)**,
So that **I don't have to reconfigure my preferred mode every time I launch the app**.

**Acceptance Criteria:**

**Given** the user was in Auto mode when the app was closed
**When** the app is launched again
**Then** the app starts in Auto mode (FR16)

**Given** the user was in Pro mode when the app was closed
**When** the app is launched again
**Then** the app starts in Pro mode with the dial controls visible

**Given** this is the first app launch (no stored preference)
**When** the app opens
**Then** Auto mode is the default

**Technical Implementation:** Use `UserDefaults` to store `lastShootingMode` key with enum value `.auto` or `.pro`. Read on launch during camera session setup.

---

## Epic 2: Manual Controls & Pro Mode

Users can switch to Pro mode and manually control ISO, Shutter Speed, Focus, and White Balance with immediate visual feedback.

### Story 2.1: Pro Mode Activation & UI Transition

As a **photography enthusiast**,
I want **to tap a "Pro" toggle to reveal manual controls**,
So that **I can access professional settings when I need creative control**.

**Acceptance Criteria:**

**Given** the app is in Auto mode
**When** the user taps the "Pro" toggle button
**Then** the Pro mode UI appears with dial controls visible in the thumb zone (bottom 180pt)
**And** the transition animation completes in under 500ms
**And** the exposure values display (ISO, Shutter, Aperture) becomes visible (FR11)

**Given** the app is in Pro mode
**When** the user taps the "Auto" toggle
**Then** the dial controls hide and the simplified Auto interface appears
**And** all manual parameters reset to automatic

**Given** Pro mode is activated
**When** 3 seconds pass without user interaction in the control zone
**Then** the controls fade to 30% opacity (per UX spec)
**And** controls return to 100% opacity immediately when touched

**Technical Implementation:** Use SwiftUI state-driven animation with `.easeInOut` timing. Implement `@State` boolean for mode tracking. Use `.opacity` modifier with animation for control fading. Integrate with `UIImpactFeedbackGenerator(style: .light)` for mode switch haptic.

---

### Story 2.2: ISO Dial Control with Real-Time Preview

As a **photographer**,
I want **to swipe on an ISO dial to adjust sensitivity with immediate preview feedback**,
So that **I can control image brightness and noise in challenging lighting**.

**Acceptance Criteria:**

**Given** Pro mode is active and the ISO dial is selected
**When** the user swipes up on the dial
**Then** the ISO value increases through standard 1/3-stops (100 → 125 → 160 → 200 → 250 → 320 → 400 → 500 → 640 → 800 → 1000 → 1250 → 1600 → 2000 → 2500 → 3200 → max)
**And** haptic feedback triggers on each stop ("tick" sensation)
**And** the live preview brightness updates within 16ms (60 FPS, NFR4)

**Given** Pro mode is active and the ISO dial is selected
**When** the user swipes down on the dial
**Then** the ISO value decreases through standard stops
**And** haptic feedback triggers on each stop

**Given** the ISO is at minimum (e.g., 100)
**When** the user attempts to swipe down further
**Then** the dial provides resistance feedback (stronger haptic)
**And** the value does not change

**Given** the ISO is at maximum (device-dependent)
**When** the user attempts to swipe up further
**Then** the dial provides resistance feedback
**And** the value does not change

**Given** the user is adjusting ISO
**When** the preview updates
**Then** no frame drops or stuttering occurs (60 FPS maintained)

**Technical Implementation:** Use `AVCaptureDevice.setExposureModeCustom(duration:iso:)` with current shutter duration to set ISO. Query `device.activeFormat.minISO` and `device.activeFormat.maxISO` for bounds. Implement gesture recognizer with velocity-based acceleration. Use `UISelectionFeedbackGenerator` for stop haptics and `UIImpactFeedbackGenerator(style: .heavy)` for boundary resistance.

**ISO Stop Values (1/3-stops):** 100, 125, 160, 200, 250, 320, 400, 500, 640, 800, 1000, 1250, 1600, 2000, 2500, 3200, 6400, 12800 (clamped to device max).

---

### Story 2.3: Shutter Speed Dial Control with Real-Time Preview

As a **photographer**,
I want **to swipe on a Shutter Speed dial to control exposure duration with immediate feedback**,
So that **I can freeze motion or create intentional blur effects**.

**Acceptance Criteria:**

**Given** Pro mode is active and the Shutter dial is selected
**When** the user swipes up on the dial
**Then** the shutter speed increases (faster) through standard 1/3-stops
**And** haptic feedback triggers on each stop
**And** the live preview exposure updates within 16ms (60 FPS, NFR4)

**Given** Pro mode is active and the Shutter dial is selected
**When** the user swipes down on the dial
**Then** the shutter speed decreases (slower) through standard stops
**And** haptic feedback triggers on each stop

**Given** the shutter speed is at minimum duration (fastest, e.g., 1/8000)
**When** the user attempts to swipe up further
**Then** resistance feedback triggers and value remains unchanged

**Given** the shutter speed is at maximum duration (slowest, device-dependent)
**When** the user attempts to swipe down further
**Then** resistance feedback triggers and value remains unchanged

**Given** manual shutter speed is set
**When** the preview renders
**Then** motion blur in the preview matches expected behavior for the shutter duration

**Technical Implementation:** Use `AVCaptureDevice.setExposureModeCustom(duration:iso:)` with `CMTime` for duration. Query `device.activeFormat.minExposureDuration` and `device.activeFormat.maxExposureDuration` for bounds. Format display using fractional notation (1/250) or seconds (1") for long exposures.

**Shutter Stop Values (1/3-stops):** 1/8000, 1/6400, 1/5000, 1/4000, 1/3200, 1/2500, 1/2000, 1/1600, 1/1250, 1/1000, 1/800, 1/640, 1/500, 1/400, 1/320, 1/250, 1/200, 1/160, 1/125, 1/100, 1/80, 1/60, 1/50, 1/40, 1/30, 1/25, 1/20, 1/15, 1/13, 1/10, 1/8, 1/6, 1/5, 1/4, 0.3", 0.4", 0.5", 0.6", 0.8", 1".

---

### Story 2.4: Manual Focus Dial Control with Visual Confirmation

As a **photographer**,
I want **to swipe on a Focus dial to manually set focus distance**,
So that **I can precisely control the plane of focus for creative effect**.

**Acceptance Criteria:**

**Given** Pro mode is active and the Focus dial is selected
**When** the user swipes up on the dial
**Then** the focus distance increases (focuses farther)
**And** haptic feedback triggers at regular intervals
**And** the live preview sharpness updates in real-time

**Given** Pro mode is active and the Focus dial is selected
**When** the user swipes down on the dial
**Then** the focus distance decreases (focuses closer)
**And** haptic feedback triggers at regular intervals

**Given** the focus is at minimum distance (closest macro)
**When** the user attempts to swipe down further
**Then** resistance feedback triggers and value remains at minimum

**Given** the focus is at infinity
**When** the user attempts to swipe up further
**Then** resistance feedback triggers and value remains at infinity

**Given** manual focus is being adjusted
**When** the dial position changes
**Then** a focus distance indicator displays (e.g., "0.3m", "1m", "∞")

**Technical Implementation:** Use `AVCaptureDevice.setFocusModeLocked(lensPosition:)` with normalized value 0.0 (near) to 1.0 (infinity). The lensPosition is a normalized float, not actual distance—display approximate distances based on lens characteristics. Use smooth interpolation for dial-to-lensPosition mapping.

---

### Story 2.5: White Balance Control with Presets and Kelvin

As a **photographer**,
I want **to select White Balance presets or set a custom Kelvin value**,
So that **I can achieve accurate or intentional color tones in my images**.

**Acceptance Criteria:**

**Given** Pro mode is active and the WB control is selected
**When** the user taps on a preset (Auto, Sunny, Cloudy, Shade, Tungsten, Fluorescent)
**Then** the white balance applies immediately to the preview
**And** the selected preset is visually indicated

**Given** the user wants custom white balance
**When** the user swipes on the WB dial
**Then** the Kelvin value changes (range: ~2000K to ~10000K)
**And** the preview color temperature updates in real-time
**And** the current Kelvin value is displayed (e.g., "5500K")

**Given** a WB preset is selected
**When** displayed
**Then** the preset name and approximate Kelvin value are shown

**WB Preset Values:**
- Auto: System-managed
- Sunny: ~5500K
- Cloudy: ~6500K
- Shade: ~7500K
- Tungsten: ~3200K
- Fluorescent: ~4000K

**Technical Implementation:** Use `AVCaptureDevice.setWhiteBalanceModeLocked(with:)` with `AVCaptureDevice.WhiteBalanceTemperatureAndTintValues`. Convert Kelvin to device gains using `device.deviceWhiteBalanceGains(for:)`. For presets, use predefined temperature/tint pairs.

---

### Story 2.6: Hardware Lens Switching (Virtual Device)

As a **photographer**,
I want **to switch between available hardware lenses (Ultra Wide, Wide, Telephoto)**,
So that **I can choose the optimal focal length for my composition**.

**Acceptance Criteria:**

**Given** the device has multiple rear cameras (e.g., iPhone 15 Pro)
**When** the lens switcher is displayed
**Then** only available lenses are shown (Ultra Wide 0.5x, Wide 1x, Telephoto 3x/5x)
**And** the current lens is visually indicated

**Given** the user taps a different lens option
**When** the lens switch is initiated
**Then** the camera smoothly transitions to the new lens using zoom factor interpolation
**And** the transition is seamless without visible cut or flash
**And** manual settings (ISO, Shutter) are preserved across the transition
**And** haptic feedback confirms the switch

**Given** the device has only one rear camera (e.g., iPhone SE)
**When** the app loads
**Then** the lens switcher is hidden or shows only "1x"

**Given** the user is on telephoto
**When** lighting is very low
**Then** the system may fall back to digital crop on wide lens (standard iOS behavior)
**And** the UI indicates this fallback if detectable

**Given** a lens switch occurs
**When** manual focus was set
**Then** focus mode reverts to auto-focus on the new lens (different optical systems)

**Technical Implementation (Virtual Multi-Camera Device - Preferred):** Use `.builtInTripleCamera` or `.builtInDualWideCamera` as a single virtual device. Control lens switching via `device.videoZoomFactor`:
- Ultra Wide: `videoZoomFactor` = 0.5 (or device-specific factor)
- Wide: `videoZoomFactor` = 1.0
- Telephoto: `videoZoomFactor` = 3.0 or 5.0 (query `device.virtualDeviceSwitchOverVideoZoomFactors` for exact switch points)

This approach provides seamless transitions without session interruption. Animate zoom factor changes using `device.ramp(toVideoZoomFactor:withRate:)` for smooth visual transitions. Query `device.constituentDevices` to determine available lenses and their switch-over points.

---

### Story 2.7: Exposure Values Display (HUD)

As a **photographer**,
I want **to see current exposure values (ISO, Shutter Speed, Aperture) at all times in Pro mode**,
So that **I always know my current settings at a glance**.

**Acceptance Criteria:**

**Given** Pro mode is active
**When** the viewfinder is displayed
**Then** current ISO value is displayed (e.g., "ISO 400")
**And** current shutter speed is displayed (e.g., "1/250")
**And** current aperture is displayed (e.g., "f/1.8")
**And** values use monospace typography (SF Mono) for alignment

**Given** any exposure parameter changes
**When** the value updates
**Then** the displayed value updates immediately (<16ms)
**And** no flickering or jarring transitions occur

**Given** the exposure display is shown
**When** viewed in bright sunlight
**Then** text maintains WCAG AA contrast (white on dark surface)

**Given** Pro mode controls fade to 30% opacity after inactivity
**When** the exposure values display
**Then** the values remain at 100% opacity (always visible)

**Technical Implementation:** Subscribe to `AVCaptureDevice` KVO on `iso`, `exposureDuration`, and `lensAperture` properties. Format shutter as fraction (1/X) when faster than 1s, as decimal seconds when slower. Aperture is read-only per lens (display `device.lensAperture`). Use SwiftUI `Text` with `.monospacedDigit()` modifier.

---

## Epic 3: Visual Aids & Capture Confidence

Users can enable histogram and focus peaking overlays, and lock exposure/focus independently to confirm their shot before capture.

### Story 3.1: Real-Time RGB Histogram Overlay

As a **photographer**,
I want **to view a real-time RGB histogram overlaid on the viewfinder**,
So that **I can verify exposure levels and avoid clipping highlights or shadows**.

**Acceptance Criteria:**

**Given** Pro mode is active
**When** the user enables the histogram toggle
**Then** a real-time RGB histogram appears in the designated position (top-right per UX spec)
**And** the histogram is semi-transparent so the viewfinder remains visible beneath

**Given** the histogram is enabled
**When** the camera preview updates each frame
**Then** the histogram updates in sync with the preview (60 FPS, NFR4)
**And** no perceptible lag exists between scene change and histogram response

**Given** the histogram is rendering
**When** the viewfinder is active
**Then** the viewfinder maintains <50ms glass-to-glass latency (NFR3)
**And** no frame drops occur on the main preview

**Given** the scene contains clipped highlights
**When** the histogram renders
**Then** the right edge of the histogram shows accumulation (spike) at maximum brightness
**And** optionally, highlight clipping is indicated with a warning color (yellow/red)

**Given** the scene contains crushed shadows
**When** the histogram renders
**Then** the left edge of the histogram shows accumulation at minimum brightness

**Given** the histogram is displayed
**When** the user taps the histogram toggle again
**Then** the histogram hides immediately

**Histogram Display Specifications:**
- Size: ~120x80pt (scalable)
- Position: Top-right corner, respecting safe area
- Opacity: 70% background with 100% histogram lines
- Channels: Combined luminance or separate R/G/B curves

**Technical Implementation:** Use Metal compute shader or Accelerate framework (`vImageHistogramCalculation`) for GPU-accelerated histogram computation. Process downsampled frames (e.g., 256x256) to reduce computation. Render histogram using Metal or Core Graphics. Pipeline: Capture CVPixelBuffer → Downsample → Compute 256 bins per channel via `vImageHistogramCalculation_ARGB8888` → Render curves via CAShapeLayer or Metal. Performance Budget: <4ms per frame.

---

### Story 3.2: Focus Peaking Overlay

As a **photographer**,
I want **to toggle Focus Peaking to highlight in-focus edges with a contrasting color**,
So that **I can confirm critical sharpness before capturing, especially when using manual focus**.

**Acceptance Criteria:**

**Given** Pro mode is active
**When** the user enables the Focus Peaking toggle
**Then** in-focus edges in the viewfinder are highlighted with a contrasting color overlay
**And** the overlay updates in real-time with the preview (60 FPS)

**Given** Focus Peaking is enabled
**When** the focus plane changes (manual dial or tap-to-focus)
**Then** the highlighted edges shift to reflect the new plane of focus immediately

**Given** Focus Peaking is rendering
**When** the viewfinder is active
**Then** the viewfinder maintains <50ms glass-to-glass latency (NFR3)
**And** no frame drops occur on the main preview

**Given** the scene has no sharp edges in the current focus plane
**When** Focus Peaking is enabled
**Then** no highlight appears (indicating nothing is in critical focus)

**Given** Focus Peaking is displayed
**When** the user taps the Focus Peaking toggle again
**Then** the overlay hides immediately

**Focus Peaking Display Specifications:**
- Highlight Color: Signal Orange (#FF9500) or user-selectable (Red, Blue, White)
- Edge Threshold: Tuned to highlight only critically sharp edges
- Overlay Mode: Additive blend over the preview

**Technical Implementation:** Use Metal compute shader for real-time edge detection: Capture CVPixelBuffer → Convert to grayscale → Apply Sobel/Laplacian edge detection kernel → Threshold edge magnitude → Apply color overlay → Composite with original frame. Performance Budget: <6ms per frame.

---

### Story 3.3: Independent AE Lock (Auto Exposure Lock)

As a **photographer**,
I want **to lock the current exposure independently from focus**,
So that **I can recompose my shot while maintaining consistent brightness**.

**Acceptance Criteria:**

**Given** the viewfinder is active (Auto or Pro mode)
**When** the user activates AE Lock (long-press on viewfinder or dedicated button)
**Then** the current exposure settings (ISO, shutter) are locked
**And** a visual indicator ("AE-L" badge) appears on screen
**And** haptic feedback confirms the lock

**Given** AE Lock is active
**When** the scene lighting changes
**Then** the exposure remains fixed at the locked values

**Given** AE Lock is active
**When** the user taps the AE Lock indicator or performs unlock gesture
**Then** the exposure unlocks and returns to automatic adjustment
**And** the "AE-L" indicator disappears

**Given** AE Lock is active
**When** the user captures a photo
**Then** the photo uses the locked exposure values

**AE Lock Visual Indicator:**
- Badge: "AE-L" in monospace font, accent orange when locked

**Technical Implementation:** Use `AVCaptureDevice.exposureMode = .locked` to freeze current exposure. Use KVO to monitor exposure mode changes.

---

### Story 3.4: Independent AF Lock (Auto Focus Lock)

As a **photographer**,
I want **to lock the current focus independently from exposure**,
So that **I can recompose my shot while maintaining the same focus plane**.

**Acceptance Criteria:**

**Given** the viewfinder is active (Auto or Pro mode)
**When** the user activates AF Lock (long-press on viewfinder or dedicated button)
**Then** the current focus distance is locked
**And** a visual indicator ("AF-L" badge) appears on screen
**And** haptic feedback confirms the lock

**Given** AF Lock is active
**When** the user moves the camera to a different subject at a different distance
**Then** the focus remains fixed at the locked distance

**Given** AF Lock is active
**When** the user taps the AF Lock indicator or performs unlock gesture
**Then** the focus unlocks and returns to continuous or tap-to-focus mode
**And** the "AF-L" indicator disappears

**Given** AF Lock is active
**When** the user captures a photo
**Then** the photo uses the locked focus distance

**AF Lock Visual Indicator:**
- Badge: "AF-L" in monospace font, accent orange when locked

**Technical Implementation:** Use `AVCaptureDevice.focusMode = .locked` to freeze current focus at `device.lensPosition`. Use KVO to monitor focus mode changes.

---

### Story 3.5: Combined AE/AF Lock Gesture

As a **photographer**,
I want **a long-press gesture that locks both exposure and focus together**,
So that **I can quickly lock the entire scene with one action when needed**.

**Acceptance Criteria:**

**Given** the viewfinder is active
**When** the user long-presses on a point for 0.5 seconds
**Then** both AE and AF lock simultaneously at that point
**And** "AE-L" and "AF-L" indicators both appear (or combined "AE/AF-L")
**And** haptic feedback confirms the lock (medium impact)
**And** the focus box animates to indicate lock state

**Given** AE/AF are both locked via long-press
**When** the user taps anywhere on the viewfinder
**Then** both locks disengage
**And** focus adjusts to the new tap point
**And** exposure returns to automatic

**Technical Implementation:** Combine `AVCaptureDevice.exposureMode = .locked` and `AVCaptureDevice.focusMode = .locked` in a single device configuration block. Implement `UILongPressGestureRecognizer` with 0.5s `minimumPressDuration`.

---

### Story 3.6: Visual Aid Toggle Controls

As a **photographer**,
I want **easily accessible toggles for histogram and focus peaking**,
So that **I can quickly enable or disable visual aids without disrupting my shooting flow**.

**Acceptance Criteria:**

**Given** Pro mode is active
**When** the visual aid controls area is displayed
**Then** toggles for Histogram and Focus Peaking are visible
**And** each toggle clearly indicates on/off state

**Given** the user has enabled visual aids
**When** the app is closed and reopened
**Then** the visual aid states persist (histogram on/off, focus peaking on/off)

**Given** visual aid toggles are displayed
**When** viewed in any lighting condition
**Then** toggles meet minimum 44x44pt touch target
**And** icons are visible with WCAG AA contrast

**Technical Implementation:** Use `UserDefaults` for persistence of toggle states. Implement as SwiftUI Toggle or custom button with icon.

---

## Epic 4: Advanced Capture & Asset Management

Users can capture in RAW/ProRAW formats and control geotagging for professional-grade asset management.

### Story 4.1: RAW (DNG) Capture Format

As a **professional photographer**,
I want **to capture images in RAW (DNG) format**,
So that **I have maximum flexibility for post-processing with full sensor data preserved**.

**Acceptance Criteria:**

**Given** the device supports RAW capture (iPhone 12+)
**When** the user enables the RAW format toggle
**Then** the capture mode switches to RAW (DNG)
**And** a "RAW" indicator is prominently displayed on screen

**Given** RAW mode is enabled
**When** the user taps the shutter button
**Then** a RAW image is captured with full sensor data
**And** the image is saved as a DNG file to the Photo Library
**And** the file contains uncompressed or losslessly compressed sensor data

**Given** RAW capture completes
**When** the file is saved
**Then** the DNG file includes all capture metadata (ISO, shutter speed, aperture, WB)
**And** the file is compatible with standard RAW editors (Lightroom, Capture One, Photos)

**Given** the device does not support RAW capture (older models)
**When** the app loads
**Then** the RAW toggle is hidden or disabled with explanation

**RAW File Specifications:**
- Format: DNG (Digital Negative) per Adobe DNG specification
- Bit Depth: 12-bit or 14-bit (device-dependent)
- Compression: Lossless or uncompressed
- Typical File Size: 20-50MB per image

**Technical Implementation:** Use `AVCapturePhotoOutput` with `AVCapturePhotoSettings`. Check `availableRawPhotoPixelFormatTypes` for RAW support. Set `rawPhotoPixelFormatType` to a supported Bayer format. In delegate callback `photoOutput(_:didFinishProcessingPhoto:)`, access `photo.fileDataRepresentation()` for DNG data. Save via `PHAssetCreationRequest.addResource(with: .photo, data:, options:)`.

---

### Story 4.2: Apple ProRAW Capture (Enhanced RAW)

As a **professional photographer with iPhone 12 Pro or later**,
I want **to capture in Apple ProRAW format**,
So that **I get computational photography benefits (Deep Fusion, Smart HDR) combined with RAW flexibility**.

**Acceptance Criteria:**

**Given** the device supports ProRAW (iPhone 12 Pro+ with iOS 14.3+)
**When** the user enables the ProRAW format toggle
**Then** the capture mode switches to Apple ProRAW
**And** a "ProRAW" indicator is prominently displayed on screen

**Given** ProRAW mode is enabled
**When** the user taps the shutter button
**Then** a ProRAW image is captured with computational enhancements baked in
**And** the image is saved as a DNG file with extended dynamic range
**And** the file size is approximately 25-40MB

**Given** ProRAW capture completes
**When** reviewed in a compatible editor
**Then** the image shows enhanced shadow/highlight detail from computational processing
**And** the file remains fully editable as a RAW file

**Given** the device does not support ProRAW
**When** the app loads
**Then** the ProRAW option is hidden, and standard RAW (if supported) is offered instead

**Technical Implementation:** Check `isAppleProRAWSupported` on `AVCapturePhotoOutput`. Enable via `isAppleProRAWEnabled = true` before capture. Use `AVCapturePhotoSettings` with `rawPhotoPixelFormatType` from `availableRawPhotoPixelFormatTypes`.

---

### Story 4.3: Format Selection Toggle (RAW/ProRAW/HEIC)

As a **photographer**,
I want **a clear toggle to switch between capture formats (HEIC, RAW, ProRAW)**,
So that **I can choose the appropriate format for my current shooting needs**.

**Acceptance Criteria:**

**Given** the format toggle is displayed
**When** the user views available options
**Then** only device-supported formats are shown:
  - All devices: HEIC/JPG
  - iPhone 12+: RAW (DNG)
  - iPhone 12 Pro+: ProRAW

**Given** the user selects a format
**When** the selection is made
**Then** the format applies immediately to subsequent captures
**And** the selected format is visually indicated
**And** haptic feedback confirms the selection

**Given** the user has selected a format
**When** the app is closed and reopened
**Then** the format preference persists

**Technical Implementation:** Store format preference in `UserDefaults`. Query device capabilities on launch via `AVCapturePhotoOutput.availableRawPhotoPixelFormatTypes` and `isAppleProRAWSupported`.

---

### Story 4.4: Location Permission Request for Geotagging

As a **user**,
I want **the app to request location access with a clear explanation when I enable geotagging**,
So that **I understand why location data is needed and can make an informed choice**.

**Acceptance Criteria:**

**Given** geotagging is disabled (default)
**When** the user enables the geotag toggle for the first time
**Then** a system location permission dialog is presented
**And** the usage description explains photos will include GPS coordinates

**Given** the user grants location permission ("While Using App")
**When** the permission is confirmed
**Then** geotagging becomes active
**And** subsequent photos include GPS metadata

**Given** the user grants "Precise" location
**When** a photo is captured with geotagging enabled
**Then** the photo includes accurate GPS coordinates

**Given** the user grants only "Approximate" location
**When** a photo is captured with geotagging enabled
**Then** the photo includes approximate GPS coordinates

**Given** the user denies location permission
**When** the denial is confirmed
**Then** the geotag toggle returns to "off" state
**And** an explanation with "Open Settings" button is shown

**Technical Implementation:** Use `CLLocationManager.requestWhenInUseAuthorization()`. Check `CLLocationManager.authorizationStatus()`. Request with Info.plist `NSLocationWhenInUseUsageDescription`.

---

### Story 4.5: Geotagging Toggle and GPS Metadata Injection

As a **photographer**,
I want **to toggle geotagging on or off to control whether my photos include location data**,
So that **I can add location context when desired or protect my privacy when needed**.

**Acceptance Criteria:**

**Given** location permission is granted
**When** the user enables the geotag toggle
**Then** geotagging becomes active
**And** a location indicator (GPS icon) appears on screen

**Given** geotagging is enabled
**When** a photo is captured
**Then** the saved image includes GPS coordinates in Exif metadata
**And** the coordinates reflect the device's location at capture time

**Given** geotagging is enabled
**When** the device cannot acquire a location fix (indoors, no signal)
**Then** the photo is saved without GPS metadata

**Given** the user disables the geotag toggle
**When** subsequent photos are captured
**Then** no GPS metadata is included in the photos (FR15)

**Given** the user changes the geotag setting
**When** the app is closed and reopened
**Then** the geotag preference persists

**Exif GPS Metadata Fields:**
- GPSLatitude, GPSLatitudeRef
- GPSLongitude, GPSLongitudeRef
- GPSAltitude, GPSAltitudeRef
- GPSDateStamp, GPSTimeStamp

**Technical Implementation:** Use `CLLocationManager` to get current location. Inject GPS metadata into `AVCapturePhotoSettings` via the `metadata` property or embed in DNG Exif during save. For PHAsset saving, use `PHAssetCreationRequest` with `creationRequest.location = CLLocation(...)`.

---

### Story 4.6: Background Save with Progress Indication

As a **photographer capturing RAW images**,
I want **the save operation to happen in the background without blocking the viewfinder**,
So that **I can continue shooting while large files are being written**.

**Acceptance Criteria:**

**Given** a photo is captured (especially RAW/ProRAW)
**When** the capture completes
**Then** the viewfinder returns to ready state immediately
**And** the save operation continues in the background
**And** the user can capture additional photos without waiting

**Given** a background save is in progress
**When** the user views the UI
**Then** a subtle save indicator is visible (e.g., small progress ring or "Saving..." badge)

**Given** multiple photos are captured rapidly
**When** saves are queued
**Then** saves process sequentially in a background queue
**And** a queue indicator shows pending saves (e.g., "Saving 3...")

**Given** all saves complete
**When** the queue is empty
**Then** the save indicator disappears

**Given** a save fails (e.g., storage full)
**When** the failure occurs
**Then** a non-blocking error notification appears
**And** retry or discard options are available

**Technical Implementation:** Use `DispatchQueue` with `.userInitiated` QoS for save operations. Implement serial queue for Photo Library writes. Use `PHPhotoLibrary.shared().performChanges` with completion handler. Track save queue state in `@Published` property.

---

### Story 4.7: Memory Management for RAW Buffers

As a **photographer using burst or continuous capture**,
I want **the app to manage memory efficiently when handling large RAW buffers**,
So that **the app remains stable and doesn't crash due to memory pressure**.

**Acceptance Criteria:**

**Given** RAW capture mode is active
**When** the user captures photos
**Then** the app manages RAW buffers efficiently
**And** buffers are released promptly after saving
**And** memory usage stays within iOS limits (NFR7)

**Given** the user captures rapidly (burst-like behavior)
**When** multiple RAW captures are in progress
**Then** the app queues captures appropriately
**And** maintains minimum 10 FPS for 3 seconds (30 frames) without dropping (NFR1)

**Given** the system signals memory pressure
**When** the app receives memory warning
**Then** the app aggressively releases cached buffers
**And** limits pending capture queue size
**And** prioritizes completing in-progress saves

**Given** extreme memory pressure occurs
**When** the app must respond immediately
**Then** the app gracefully cancels pending captures rather than crashing

**Technical Implementation:** Use autoreleasepool blocks around capture callbacks. Monitor memory via `os_proc_available_memory()`. Set capture queue depth limits. Subscribe to `UIApplication.didReceiveMemoryWarningNotification`. For burst, check `supportedMaxPhotoDimensions` for buffer sizing.

---

### Story 4.8: Storage Space Awareness

As a **photographer**,
I want **the app to warn me when storage space is low before I capture large RAW files**,
So that **I don't lose shots due to failed saves**.

**Acceptance Criteria:**

**Given** device storage is low (< 500MB free)
**When** the user has RAW/ProRAW mode enabled
**Then** a warning indicator appears ("Low Storage")
**And** estimated remaining RAW shots is displayed

**Given** device storage is critically low (< 100MB free)
**When** the user attempts to capture
**Then** a more prominent warning is shown

**Given** a save fails due to insufficient storage
**When** the error occurs
**Then** the user is clearly notified ("Storage Full - Photo not saved")
**And** suggestion to free space or switch to HEIC is provided

**Given** storage was low but space is freed
**When** the app checks storage again
**Then** the warning disappears

**Technical Implementation:** Query available storage via `FileManager.default.attributesOfFileSystem(forPath:)` with key `FileAttributeKey.systemFreeSize`. Calculate estimated remaining shots based on ~30MB average RAW size. Check storage on app foreground and before capture.

---

## Requirements Coverage Summary

### Functional Requirements (18 FRs) - All Covered

| FR | Description | Epic | Story |
|----|-------------|------|-------|
| FR1 | Manual ISO adjustment | Epic 2 | 2.2 |
| FR2 | Manual Shutter Speed adjustment | Epic 2 | 2.3 |
| FR3 | Manual Focus adjustment | Epic 2 | 2.4 |
| FR4 | White Balance presets/Kelvin | Epic 2 | 2.5 |
| FR5 | Auto mode toggle | Epic 1 | 1.6 |
| FR6 | Hardware lens switching | Epic 2 | 2.6 |
| FR7 | Real-time RGB histogram | Epic 3 | 3.1 |
| FR8 | Focus Peaking toggle | Epic 3 | 3.2 |
| FR9 | Tap-to-focus | Epic 1 | 1.4 |
| FR10 | AE/AF Lock | Epic 3 | 3.3, 3.4, 3.5 |
| FR11 | Exposure values display | Epic 2 | 2.1, 2.7 |
| FR12 | RAW (DNG) capture | Epic 4 | 4.1, 4.2, 4.3 |
| FR13 | HEIC/JPG capture | Epic 1 | 1.5 |
| FR14 | Save to Photo Library | Epic 1 | 1.5; Epic 4 | 4.6 |
| FR15 | Geotagging toggle | Epic 4 | 4.4, 4.5 |
| FR16 | Persist shooting mode | Epic 1 | 1.7 |
| FR17 | Permission requests | Epic 1 | 1.1, 1.2; Epic 4 | 4.4 |
| FR18 | Handle denied permissions | Epic 1 | 1.1, 1.2 |

### Non-Functional Requirements (9 NFRs) - All Addressed

| NFR | Description | Coverage |
|-----|-------------|----------|
| NFR1 | 10 FPS RAW burst for 3 seconds | Epic 4: Story 4.7 |
| NFR2 | < 1.5s cold launch | Epic 1: Story 1.3 |
| NFR3 | < 50ms viewfinder latency | Epic 1: 1.3; Epic 3: 3.1, 3.2 |
| NFR4 | 60 FPS dial interactions | Epic 2: 2.2, 2.3; Epic 3: 3.1, 3.2 |
| NFR5 | Thermal throttling | Architecture cross-cutting |
| NFR6 | > 99.5% crash-free | All stories with error handling |
| NFR7 | Memory management | Epic 4: 4.6, 4.7, 4.8 |
| NFR8 | Privacy - no data collection | All permission stories |
| NFR9 | Limited Photo Access handling | Epic 1: Story 1.2 |

### Story Count Summary

| Epic | Title | Stories |
|------|-------|---------|
| Epic 1 | Core Camera Foundation & Basic Capture | 7 |
| Epic 2 | Manual Controls & Pro Mode | 7 |
| Epic 3 | Visual Aids & Capture Confidence | 6 |
| Epic 4 | Advanced Capture & Asset Management | 8 |
| **Total** | | **28 Stories** |

