# Story 2.1: Pro Mode Activation & UI Transition

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **photography enthusiast**,
I want **to tap a "Pro" toggle to reveal manual controls**,
so that **I can access professional settings when I need creative control**.

## Acceptance Criteria

### AC1: Pro Mode Activation & Transition
**Given** the app is in Auto mode
**When** the user taps the "Pro" toggle button
**Then** the manual control interface (`ProControlView`) appears in the thumb zone (bottom 180pt)
**And** the transition animation completes in under 500ms using `.easeInOut`
**And** the exposure values HUD (ISO, Shutter, Aperture) becomes visible (FR11)
**And** haptic feedback (`.light`) confirms the mode switch (partially covered in Story 1.6)

### AC2: Return to Auto Mode
**Given** the app is in Pro mode
**When** the user taps the "Auto" toggle
**Then** the dial controls hide and the simplified Auto interface takes over
**And** all manual parameters reset to automatic (handled by `CameraEngine.resetToAuto()`)
**And** the transition is smooth and reversible

### AC3: Controls Inactivity Fading
**Given** Pro mode is active
**When** 3 seconds pass without user interaction in the control zone
**Then** the controls fade to 30% opacity
**And** the exposure HUD remains at 100% opacity (per Story 2.7/AC4)

### AC4: Controls Reactivation
**Given** the controls rely found 30% opacity
**When** the user touches the control zone
**Then** the controls return to 100% opacity immediately

## Tasks / Subtasks

- [x] Task 1: Create Pro Controls Container (AC: #1)
  - [x] Create `ProControlView.swift` to house the manual dials (scaffolding for ISO/Shutter/Focus dials).
  - [x] Create `ExposureHUDView.swift` to display ISO, Shutter, and Aperture (scaffolding for Story 2.7).
  - [x] Implement a placeholder layout for the dials (e.g., TabView or similar switcher) to verify spacing in the bottom 180pt thumb zone.

- [x] Task 2: Implement UI Transitions (AC: #1, #2)
  - [x] Update `ViewfinderContainerView` to conditionally show `ProControlView` and `ExposureHUDView` based on `viewModel.mode`.
  - [x] Apply `.transition(.move(edge: .bottom).combined(with: .opacity))` or similar `.easeInOut` animation with <500ms duration.
  - [x] Ensure `ModeToggleView` remains accessible and visible during/after transition.

- [x] Task 3: Implement Inactivity Fading Logic (AC: #3, #4)
  - [x] create a `ControlFader` observable or logic within `ProControlView` that uses a `Timer` or `DispatchQueue.asyncAfter`.
  - [x] Detect touches/gestures in the control zone to reset the timer and restore opacity.
  - [x] Ensure the HUD does *not* fade (apply opacity modifier only to the dials container).

- [x] Task 4: UI Verification & Polish
  - [x] Verify haptic feedback correctness during transitions.
  - [x] Verify the bottom safe area handling for the new Pro controls.
  - [x] Ensure landscape orientation behavior is defined (or locked if portrait-only).

## Dev Notes

### Technical Implementation Details

**Animation & Transitions:**
Use `withAnimation(.easeInOut(duration: 0.3))` for the mode switch. The `ProControlView` should seemingly slide up or fade in.

```swift
if viewModel.mode == .pro {
    ProControlView()
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .zIndex(1)
}
```

**Fading Logic:**
Consider a custom `ViewModifier` or a wrapper view that listens for drag/tap gestures to reset an `opacity` state.

```swift
.onReceive(timer) { _ in
    if timeSinceLastTouch > 3.0 {
        withAnimation { opacity = 0.3 }
    }
}
.gesture(DragGesture(minimumDistance: 0).onChanged { _ in
    opacity = 1.0
    lastTouchTime = Date()
})
```

### Architecture Compliance

| Requirement | Implementation |
|-------------|----------------|
| **Thumb Zone** | Controls must occupy the bottom ~180pt area for reachable one-handed use. |
| **Performance** | Animations must be 60fps and non-blocking (<500ms). |
| **Feedback** | Visual and haptic feedback for all mode changes. |

### Project Structure Notes

```
Camera/
├── Features/
│   ├── Viewfinder/
│   │   ├── Views/
│   │   │   ├── ProControlView.swift (New)
│   │   │   ├── ExposureHUDView.swift (New)
│   │   │   └── ViewfinderContainerView.swift (Update)
│   │   └── ViewModels/
│   │       └── CameraViewModel.swift (Update if fader logic needs VM support)
```

### References

- [Source: docs/epics/epic-2-manual-controls-pro-mode.md#Story 2.1]
- [Source: _bmad-output/implementation-artifacts/1-6-auto-mode-toggle.md] (Existing toggle logic)
- [Source: docs/architecture/component-architecture.md]

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List
- Implemented `ProControlView` with 3-second inactivity fading timer.
- Implemented `ExposureHUDView` with monospaced font support.
- Integrated views into `ViewfinderContainerView` with smooth transitions.
- Adjusted z-index to ensure Shutter Button remains clickable in Pro Mode.

### File List
- Camera/Camera/Features/Viewfinder/Views/ProControlView.swift (New)
- Camera/Camera/Features/Viewfinder/Views/ExposureHUDView.swift (New)
- Camera/Camera/Features/Viewfinder/Views/ViewfinderContainerView.swift (Modified)
### Change Log
- **Review Fixes ({{date}})**:
  - Added `withAnimation` to `ViewfinderContainerView` mode toggle (Status: Fixed).
  - Refactored `ProControlView` to use `ProControlViewModel` for testable fading logic (Status: Fixed).
  - Added `testProControlViewModelInactivityLogic` to verify AC3 (Status: Fixed).

### File List
- Camera/Camera/Features/Viewfinder/Views/ProControlView.swift (Refactored)
- Camera/Camera/Features/Viewfinder/Views/ExposureHUDView.swift (New)
- Camera/Camera/Features/Viewfinder/Views/ViewfinderContainerView.swift (Modified)
- CameraTests/ProControlViewTests.swift (Updated)
