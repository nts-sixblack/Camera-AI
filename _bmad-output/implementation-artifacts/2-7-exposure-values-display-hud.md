# Story 2.7: Exposure Values Display (HUD)

**Story ID:** 2.7
**Type:** Story
**Status:** ready-for-dev
**Priority:** High
**Epic:** Manual Controls & Pro Mode (Epic 2)

## Description

As a **photographer**, I want **to see current exposure values (ISO, Shutter Speed, Aperture) at all times in Pro mode**, So that **I always know my current settings at a glance**.

When shooting in Pro Mode, users need immediate verification of their exposure settings. This HUD (Head-Up Display) should present the real-time ISO, Shutter Speed, and Aperture values directly on top of the viewfinder, ensuring photographers can monitor these critical parameters without looking away from their composition.


## Tasks / Subtasks

- [x] Task 1: Modify CameraEngine for Exposure Observation (AC: #1, #2)
  - [x] Add KVO observers for `iso`, `exposureDuration`, and `lensAperture`
  - [x] Expose `@Published` properties `currentISO`, `currentShutterSpeed`, `currentAperture`
  - [x] Ensure updates occur on main thread

- [x] Task 2: Create ExposureHUDViewModel (AC: #3)
  - [x] Create `ExposureHUDViewModel`
  - [x] Implement formatting logic for Shutter Speed (fractions vs seconds)
  - [x] Implement formatting logic for Aperture ("f/x.x")
  - [x] Add Unit Tests for formatting logic

- [x] Task 3: Create ExposureHUDView (AC: #1, #4, #5)
  - [x] Create `ExposureHUDView` using SF Mono 17pt (Medium)
  - [x] Implement layout (HStack/VStack)
  - [x] Bind to ViewModel/CameraEngine
  - [x] Ensure 100% opacity in Pro Mode

- [x] Task 4: Integration (AC: #1)
  - [x] Add `ExposureHUDView` to `ViewfinderContainerView` ZStack
  - [x] Verify positioning above preview/below controls

## Acceptance Criteria


### AC1: Pro Mode HUD Visibility
**Given** Pro mode is active
**When** the viewfinder is displayed
**Then** current ISO value is displayed (e.g., "ISO 400")
**And** current shutter speed is displayed (e.g., "1/250")
**And** current aperture is displayed (e.g., "f/1.8")
**And** the HUD is positioned clearly over the viewfinder (refer to UX spec)
**And** values use monospace typography (SF Mono) for alignment

### AC2: Real-time Value Updates
**Given** any exposure parameter changes (either by manual adjustment or auto-exposure shift)
**When** the value updates on the hardware
**Then** the displayed value updates immediately (<16ms latency target)
**And** no flickering or jarring transitions occur during rapid changes

### AC3: Value Formatting
**Given** the shutter speed is faster than 1 second
**Then** it is displayed as a fraction (e.g., "1/1000", "1/48")
**Given** the shutter speed is 1 second or slower
**Then** it is displayed as decimal seconds with a quote mark (e.g., "1\"", "0.5\"" if applicable)
**Given** Aperture value
**Then** it is formatted with "f/" prefix (e.g., "f/1.8", "f/2.4")

### AC4: Visual Readability & Accessibility
**Given** the exposure display is shown
**When** viewed in bright sunlight or against varied backgrounds
**Then** text maintains WCAG AA contrast (White text, optionally with shadow or subtle backing)
**And** font size matches UX spec (17pt Medium)

### AC5: Persistence
**Given** Pro mode controls fade to 30% opacity after inactivity (as per Story 2.1)
**When** the exposure values display is active
**Then** the exposure values remain at 100% opacity (always visible while in Pro Mode)

## Developer Context

### 🏗️ Technical & Architectural Requirements
*   **Core Service:** Modify `CameraEngine` (Singleton) to observe `AVCaptureDevice` properties.
    *   **KVO Req:** Observe `iso`, `exposureDuration`, and `lensAperture`.
    *   **Publishing:** Expose these as `@Published` read-only properties (e.g., `currentISO`, `currentShutterSpeed`, `currentAperture`) on `CameraEngine` for SwiftUI binding.
    *   **Performance:** Ensure KVO updates happen on main thread if binding directly to UI, or use a throttle if hardware updates are excessive (though <16ms requirement implies direct feed).
*   **ViewModel:** Create `ExposureHUDViewModel`.
    *   **Responsibility:** Transform raw values (`float`, `CMTime`) into formatted strings.
    *   **Formatting Logic:** Isolate formatting logic (Fraction conversion for shutter speed) for unit testing.
*   **View:** Create `ExposureHUDView`.
    *   **Composition:** Use `HStack` or `VStack` as per visual design alignment.
    *   **Integration:** Add to `ViewfinderContainerView` within the ZStack, ensuring it sits *above* the camera preview but *below* the main Pro Controls if they overlap.
    *   **Tags:** Accessibility labels are mandatory.

### 🎨 UX & Design Specifications
*   **Typography:** **SF Mono**, Medium Weight, 17pt.
*   **Color:** Text Primary (White `#FFFFFF`).
*   **Placement:** "Thumb Zone" bottom 180pt check - verify if this HUD goes effectively in the top area or bottom. Epic/UX doesn't explicitly state *position* in AC, but "Thumb Zone controls" usually implies interactive elements bottom. Readouts often go top or bottom. *Decision: Consult `ViewfinderContainerView` structure. Usually top or just above controls.*
    *   *Self-Correction based on 'Visual Design Foundation':* "Viewfinder Margin: 0pt". "Controls float on top".
*   **Assets:** SF Symbols not required for values, but standard text only.

### 🧩 File Structure Guidelines
*   `Camera/Features/Viewfinder/CameraEngine.swift` (Modify: Add Observable capabilities)
*   `Camera/Features/Viewfinder/ViewModels/ExposureHUDViewModel.swift` (New)
*   `Camera/Features/Viewfinder/Views/Overlays/ExposureHUDView.swift` (New: Suggest 'Overlays' folder or 'ManualControls')
*   `CameraTests/Features/Viewfinder/ExposureHUDViewModelTests.swift` (New)

### 🧪 Testing Requirements
*   **Unit Tests:**
    *   Test `ExposureHUDViewModel` formatting logic (e.g., verify `CMTime(1, 250)` becomes "1/250").
    *   Verify Aperture formatting.
*   **Manual Verification:**
    *   Launch Pro Mode.
    *   Verify values match external light meter or expected changes when pointing at light/dark areas (if Auto) or changing dials (if Manual).
    *   Verify persistence when controls fade.

### 💡 Implementation Tips
*   **Shutter Speed:** `AVCaptureDevice.exposureDuration` is a `CMTime`. Use `CMTimeGetSeconds` for logic, but for display, find the nearest standard fraction denominator if strictly matching dial, or show exact. HUD usually shows *exact* current value.
*   **Aperture:** On iPhone, aperture is fixed per lens. It will only change if the user switches lenses (Story 2.6). Ensure it updates if `CameraEngine` switches input device.
*   **Preview Matches Reality:** Ensure the displayed value is observing `device.iso`, not just a local target state variable. The HUD must reflect *actual* hardware state.

## Git Intelligence (Previous Work)
*   **Story 2.6 (Lens Switching):** Established `LensSwitcherView` in `ViewfinderContainerView`.
*   **Pattern:** MVVM with `CameraEngine` as the central data source.
*   **Commit History:** Recent changes in `CameraEngine.swift` added `setZoomFactor`. This story will add KVO observers.

## Project Context
*   **Architecture:** Adhere strictly to MVVM. No business logic in Views.
*   **Design System:** Use `Font.custom("SFMono-Medium", size: 17)` or `Font.system(size: 17, weight: .medium, design: .monospaced)`. *Correction: SwiftUI standard `font(.system(.body, design: .monospaced))` might be safer/easier.*
