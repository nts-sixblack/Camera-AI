# Story 1.6: Auto Mode Toggle

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **user**,
I want **a visible "Auto" button that resets all settings to automatic mode**,
so that **I can quickly return to point-and-shoot simplicity or hand my phone to someone else**.

## Acceptance Criteria

### AC1: Instant Reset to Automatic
**Given** the app is in Pro mode with manual settings applied (even if simulated for now)
**When** the user taps the "Auto" button
**Then** all manual camera parameters are reset to continuous automatic modes (FR5)
**And** the UI transitions to the simplified Auto mode view
**And** the transition completes in under 500ms

### AC2: Toggle UI Implementation
**Given** the app is running
**When** the UI is displayed
**Then** an "Auto/Pro" toggle is visible and accessible in the thumb zone
**And** the active mode is clearly indicated (e.g., "Auto" highlighted)
**And** the button has a minimum 44x44pt touch target and WCAG AA contrast

### AC3: State Synchronization
**Given** the user toggles from Pro to Auto
**Then** the `CameraEngine` immediately updates the `AVCaptureDevice` configuration
**And** any manual focus indicators or overlays are dismissed

### AC4: Haptic Feedback
**Given** the mode is changed via the toggle
**When** the tap occurs
**Then** a light haptic feedback (`.light`) is triggered to confirm the mode shift

## Tasks / Subtasks

- [ ] Task 1: Implement Mode State Management (AC: #1, #3)
  - [ ] Create a `CameraMode` enum (`.auto`, `.pro`)
  - [ ] Implement a centralized `AppStateMachine` or observable view model to track the current mode
- [ ] Task 2: Create Mode Toggle View (AC: #2, #4)
  - [ ] Design a SwiftUI `ModeToggleView` matching the dark theme
  - [ ] Implement the "Auto" and "Pro" labels with Signal Orange (#FF9500) accent for active state
  - [ ] Add `UIImpactFeedbackGenerator(style: .light)` to the toggle action
- [ ] Task 3: Implement Reset Logic in Camera Engine (AC: #1, #3)
  - [ ] Create `resetToAuto()` method in `CameraEngine`
  - [ ] Set `focusMode` to `.continuousAutoFocus`
  - [ ] Set `exposureMode` to `.continuousAutoExposure`
  - [ ] Set `whiteBalanceMode` to `.continuousAutoWhiteBalance`
- [ ] Task 4: Integrate Toggle into Main View (AC: #2)
  - [ ] Place the toggle in the lower section of the `ViewfinderView` (thumb zone)
  - [ ] Ensure the UI layout adapts to the mode change (hiding/showing controls)
- [ ] Task 5: Write State Transition Tests (NFR6)
  - [ ] Verify that `resetToAuto()` correctly updates the `AVCaptureDevice` properties

## Dev Notes

### Technical Implementation Details

**State Transition Pattern:**
Using a centralized state object ensures that the UI and the hardware remain in sync.

```swift
@MainActor
class CameraViewModel: ObservableObject {
    @Published var mode: CameraMode = .auto

    func toggleMode() {
        mode = (mode == .auto) ? .pro : .auto
        if mode == .auto {
            cameraEngine.resetToAuto()
        }
    }
}
```

**Hardware Reset:**
```swift
func resetToAuto() {
    do {
        try device.lockForConfiguration()
        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }
        if device.isExposureModeSupported(.continuousAutoExposure) {
            device.exposureMode = .continuousAutoExposure
        }
        if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
            device.whiteBalanceMode = .continuousAutoWhiteBalance
        }
        device.unlockForConfiguration()
    } catch {
        // Handle error
    }
}
```

### Architecture Compliance

| Requirement | Implementation |
|-------------|----------------|
| **UX Performance** | Transition < 500ms. |
| **UX Consistency** | Signal Orange (#FF9500) for active mode state. |
| **Touch Targets** | 44x44pt minimum for the toggle. |

### Project Structure Notes

```
Camera/
├── App/
│   └── CameraViewModel.swift       # Central state management
├── Features/
│   ├── Viewfinder/
│   │   └── CameraEngine.swift (Update)
│   └── Navigation/
│       └── Views/
│           └── ModeToggleView.swift # New component
```

### Previous Story Intelligence (Story 1.3, 1.4, 1.5)
- The toggle will eventually show/hide the dials from Epic 2.
- For now, ensure it clears any tap-to-focus indicators from Story 1.4 when returning to Auto.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.6]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Key Design Challenges]
- [Apple Docs: AVCaptureDevice.ExposureMode](https://developer.apple.com/documentation/avfoundation/avcapturedevice/exposuremode)

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent)

### Debug Log References

### Completion Notes List

### File List
