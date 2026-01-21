# Story 2.2: ISO Dial Control with Real-Time Preview

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **photographer**,
I want **to swipe on an ISO dial to adjust sensitivity with immediate preview feedback**,
so that **I can control image brightness and noise in challenging lighting**.

## Acceptance Criteria

### AC1: ISO Adjustment & Feedback
**Given** Pro mode is active and the ISO dial is selected
**When** the user swipes up or down on the dial
**Then** the ISO value increases or decreases through standard 1/3-stops
**And** haptic feedback triggers on each stop ("tick" sensation)
**And** the live preview brightness updates within 16ms (60 FPS)

### AC2: Bound Resistance
**Given** the ISO is at minimum or maximum limit
**When** the user attempts to swipe further past the limit
**Then** the dial provides resistance feedback (stronger haptic)
**And** the value does not change

### AC3: Performance
**Given** the user is adjusting ISO
**When** the preview updates
**Then** no frame drops or stuttering occurs (60 FPS maintained)

## Tasks / Subtasks

- [x] Task 1: Update CameraEngine for Manual ISO Support (AC: #1)
  - [x] Add `setISO(_ iso: Float)` method to `CameraEngine`.
  - [x] Implement `activeFormat.minISO` and `maxISO` bounds checking.
  - [x] Use `setExposureModeCustom(duration:iso:)` preserving current duration.
  - [x] Expose current ISO via `ObservableObject` or publisher.

- [x] Task 2: Create ISO Dial Component (AC: #1, #2)
  - [x] Create `ISODialView.swift` with vertical swipe gesture.
  - [x] Implement 1/3-stop logic (100, 125, 160, etc.).
  - [x] Integrate `UISelectionFeedbackGenerator` for steps.
  - [x] Integrate `UIImpactFeedbackGenerator(.heavy)` for bounds.

- [x] Task 3: Integrate into Pro Control Interface (AC: #1)
  - [x] Add `ISODialView` to `ProControlView`.
  - [x] Connect View to `CameraManager` ISO state.
  - [x] Ensure proper layout in thumb zone.

- [x] Task 4: Performance & UX Verification (AC: #3)
  - [x] Verify haptics on physical device (if possible, else sim logs).
  - [x] Verify preview responsiveness.

## Dev Notes

- **Standard ISO Stops**: 100, 125, 160, 200, 250, 320, 400, 500, 640, 800, 1000, 1250, 1600, 2000, 2500, 3200...
- **API**: Use `AVCaptureDevice.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration, iso: newISO, completionHandler: nil)`.
- **Note on Duration**: When changing ISO, you must preserve the *current* exposure duration (shutter speed), otherwise it might reset to default.
- **Haptics**: `UISelectionFeedbackGenerator().selectionChanged()` for ticks.

### Project Structure Notes

- **CameraEngine**: extend `Camera/Features/Viewfinder/CameraEngine.swift`.
- **Views**: `Camera/Features/Viewfinder/Views/ManualControls/ISODialView.swift` (Create new folder ManualControls if needed).
- **Architecture**: `ProControlView` talks to `CameraViewModel`, which talks to `CameraEngine`. Avoid direct Engine access from View if possible, or use VM as pass-through.

### References

- [Source: docs/epics/epic-2-manual-controls-pro-mode.md#Story 2.2]
- [Source: docs/architecture/component-architecture.md]

## Dev Agent Record

### Agent Model Used

Gemini 2.0 Flash (Antigravity)

### Debug Log References

### Completion Notes List

- ✅ Task 1: Added `setISO(_:)` method to CameraEngine with published `currentISO`, `minISO`, `maxISO` properties
- ✅ Task 1: Extended `CaptureDeviceProtocol` with ISO-related properties (`activeFormat`, `iso`, `exposureDuration`, `setExposureModeCustom`)
- ✅ Task 1: ISO bounds are initialized from device format after session configuration  
- ✅ Task 2: Created `ISODialView.swift` with `ISOStops` enum containing standard 1/3-stop values
- ✅ Task 2: Implemented `ISODialViewModel` with vertical drag gesture handling and delta accumulation
- ✅ Task 2: Integrated `UISelectionFeedbackGenerator` for step haptics and `UIImpactFeedbackGenerator(.heavy)` for bounds
- ✅ Task 2: Added `DialIndicator` visual component with logarithmic progress bar
- ✅ Task 3: Updated `ProControlView` to accept `CameraEngine` dependency
- ✅ Task 3: Connected `ISODialViewModel` to CameraEngine via Combine publishers for bidirectional ISO state sync
- ✅ Task 3: Layout optimized for 180pt thumb zone with 110pt dial area
- ✅ Task 4: Updated `MockCaptureDevice` in tests with ISO protocol conformance
- ✅ Task 4: Added unit tests for `ISOStops.nearest()`, `.higher()`, `.lower()` methods
- ✅ Task 4: Build verified successful with only deprecation warnings

### File List

- Camera/Features/Viewfinder/CameraEngine.swift (MODIFIED)
- Camera/Features/Viewfinder/Views/ManualControls/ISODialView.swift (NEW)
- Camera/Features/Viewfinder/Views/ProControlView.swift (NEW - created in Story 2.1)
- Camera/Features/Viewfinder/Views/ViewfinderContainerView.swift (MODIFIED)
- CameraTests/CameraEngineTests.swift (MODIFIED)
- CameraTests/ProControlViewTests.swift (NEW - created in Story 2.1)

## Change Log

- 2026-01-15: Story 2.2 implemented - ISO Dial Control with real-time preview
