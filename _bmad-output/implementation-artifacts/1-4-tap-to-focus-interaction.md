# Story 1.4: Tap-to-Focus Interaction

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **user**,
I want **to tap anywhere on the viewfinder to set the focus point**,
so that **I can control what part of the scene is in sharp focus**.

## Acceptance Criteria

### AC1: Tap-to-Focus Initialization
**Given** the viewfinder is active
**When** the user taps on a point in the viewfinder
**Then** the camera adjusts focus to that specific point
**And** the camera adjusts exposure to that point (standard iOS behavior for auto-mode)

### AC2: Focus Indicator UI
**Given** a tap-to-focus action is initiated
**When** the tap occurs
**Then** a focus indicator (square) appears at the tap location
**And** the indicator animates (e.g., scales down slightly or pulses)
**And** the indicator fades out within 1.5 seconds

### AC3: Focus Refinement
**Given** the user taps on a new point while a focus indicator is already visible
**Then** the focus immediately adjusts to the new tap location
**And** the previous indicator disappears
**And** a new indicator appears at the new location

### AC4: Focus Hunting Feedback
**Given** the camera is unable to achieve a focus lock at the tapped point (e.g., too dark)
**When** the focus hunting occurs
**Then** the focus indicator pulses or changes color slightly to indicate failure/hunting

## Tasks / Subtasks

- [ ] Task 1: Coordinate Conversion Logic (AC: #1)
  - [ ] Implement conversion from `CGPoint` (UI coordinates) to camera coordinates (normalized 0.0 to 1.0)
  - [ ] Use `AVCaptureVideoPreviewLayer.captureDevicePointConverted(fromLayerPoint:)`
- [ ] Task 2: Implement Focus Logic in Camera Engine (AC: #1)
  - [ ] Create `focus(at: CGPoint)` method in `CameraEngine`
  - [ ] Lock configuration, set `focusPointOfInterest`, and set `focusMode` to `.autoFocus` (or `.continuousAutoFocus`)
  - [ ] Similarly set `exposurePointOfInterest` and `exposureMode`
- [ ] Task 3: Create Focus Indicator View (AC: #2, #3, #4)
  - [ ] Design a SwiftUI `FocusIndicatorView` (simple square with Signal Orange #FF9500 border)
  - [ ] Implement animation for appearance and disappearance
  - [ ] Integrate the indicator into the `ViewfinderView` using a `ZStack`
- [ ] Task 4: Gesture Integration (AC: #1, #2)
  - [ ] Add a `TapGesture` to the `ViewfinderView`
  - [ ] Capture the location of the tap and trigger the focus logic
- [ ] Task 5: Write Unit Tests (NFR6)
  - [ ] Test the coordinate conversion logic (mocking the preview layer if possible)
  - [ ] Test that the focus command is sent to the `AVCaptureDevice`

## Dev Notes

### Technical Implementation Details

**Camera Coordinate System:**
Camera coordinates are normalized (0,0 to 1,1) where (0,0) is top-left in the **sensor's landscape orientation**. `AVCaptureVideoPreviewLayer` provides the utility to handle the rotation and scaling for you.

**Focus Code Snippet:**
```swift
func focus(at point: CGPoint) {
    let device = captureDevice
    do {
        try device.lockForConfiguration()

        if device.isFocusPointOfInterestSupported {
            device.focusPointOfInterest = point
            device.focusMode = .autoFocus
        }

        if device.isExposurePointOfInterestSupported {
            device.exposurePointOfInterest = point
            device.exposureMode = .continuousAutoExposure
        }

        device.isSubjectAreaChangeMonitoringEnabled = true
        device.unlockForConfiguration()
    } catch {
        print("Could not lock configuration: \(error)")
    }
}
```

### Architecture Compliance

| Requirement | Implementation |
|-------------|----------------|
| **UX Consistency** | Use Signal Orange (#FF9500) for the focus indicator. |
| **Performance** | Focus adjustment must be near-instant. |
| **Accessibility** | VoiceOver should announce "Focus set at [position]". |

### Project Structure Notes

```
Camera/
├── Features/
│   └── Viewfinder/
│       ├── CameraEngine.swift (Update)
│       └── Views/
│           ├── ViewfinderView.swift (Update)
│           └── FocusIndicatorView.swift # New component
```

### Previous Story Intelligence (Story 1.3)
- Ensure the `ViewfinderView` correctly exposes the `AVCaptureVideoPreviewLayer` to the `CameraEngine` for coordinate conversion.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.4]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Core User Experience]
- [Apple Docs: AVCaptureDevice.focusPointOfInterest](https://developer.apple.com/documentation/avfoundation/avcapturedevice/1624644-focuspointofinterest)

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent)

### Debug Log References

### Completion Notes List

### File List
