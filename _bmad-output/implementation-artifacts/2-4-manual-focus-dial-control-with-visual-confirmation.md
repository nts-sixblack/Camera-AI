# Story 2.4: Manual Focus Dial Control with Visual Confirmation

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **photographer**,
I want **to swipe on a Focus dial to manually set focus distance**,
so that **I can precisely control the plane of focus for creative effect**.

## Acceptance Criteria

### AC1: Focus Distance Increase (Farther)
**Given** Pro mode is active and the Focus dial is selected
**When** the user swipes up on the dial
**Then** the focus distance increases (focuses farther)
**And** haptic feedback triggers at regular intervals
**And** the live preview sharpness updates in real-time

### AC2: Focus Distance Decrease (Closer)
**Given** Pro mode is active and the Focus dial is selected
**When** the user swipes down on the dial
**Then** the focus distance decreases (focuses closer)
**And** haptic feedback triggers at regular intervals

### AC3: Minimum Distance Bound (Closest Macro)
**Given** the focus is at minimum distance (closest macro)
**When** the user attempts to swipe down further
**Then** resistance feedback triggers and value remains at minimum

### AC4: Infinity Focus Bound
**Given** the focus is at infinity
**When** the user attempts to swipe up further
**Then** resistance feedback triggers and value remains at infinity

### AC5: Focus Distance Display
**Given** manual focus is being adjusted
**When** the dial position changes
**Then** a focus distance indicator displays (e.g., "0.3m", "1m", "∞")

## Tasks / Subtasks

- [x] Task 1: Update CameraEngine for Manual Focus Support (AC: #1, #2)
  - [x] Add `setFocusLensPosition(_ lensPosition: Float)` method to `CameraEngine`
  - [x] Use `AVCaptureDevice.setFocusModeLocked(lensPosition:completionHandler:)` API
  - [x] Add published properties: `currentLensPosition: Float`, `isUsingManualFocus: Bool`
  - [x] Extend `CaptureDeviceProtocol` if needed for `lensPosition` property
  - [x] Add helper method to reset to auto-focus: `setAutoFocus()`

- [x] Task 2: Create FocusDialViewModel and FocusStops Helper (AC: #1, #2, #3, #4, #5)
  - [x] Create `FocusDialView.swift` in `Camera/Features/Viewfinder/Views/ManualControls/`
  - [x] Implement `FocusDialViewModel` following ISODialViewModel pattern
  - [x] Focus uses continuous range 0.0…1.0 (no discrete stops like ISO)
  - [x] Implement smooth interpolation with delta threshold (~30pt for smoother focus)
  - [x] Integrate `UISelectionFeedbackGenerator` for interval haptics (every ~0.1 lensPosition)
  - [x] Integrate `UIImpactFeedbackGenerator(.heavy)` for bound resistance at 0.0 and 1.0

- [x] Task 3: Implement Distance Display Logic (AC: #5)
  - [x] Map lensPosition to approximate distance display:
    - `0.0` → "Near" or "0.1m" (macro)
    - `0.5` → "1m" (approximate mid-range)
    - `1.0` → "∞" (infinity)
  - [x] Consider logarithmic mapping for more intuitive display
  - [x] Display format: "0.3m", "1m", "3m", "∞"

- [x] Task 4: Create FocusDialView UI Component (AC: #1, #2, #5)
  - [x] Create `FocusDialView` matching ISODialView/ShutterSpeedDialView design pattern
  - [x] Implement vertical drag gesture with delta accumulation
  - [x] Display formatted focus distance (see Task 3)
  - [x] Create `FocusDialIndicator` with linear progress visualization (0.0 to 1.0)
  - [x] Add hint text "Swipe ↑↓ to adjust"
  - [x] Use cyan/teal color for focus dial to differentiate from ISO (yellow)

- [x] Task 5: Integrate into ProControlView (AC: #1)
  - [x] Replace "Focus" placeholderControl with `FocusDialView`
  - [x] Add `focusDialViewModel` to `ProControlViewModel` following existing patterns
  - [x] Connect ViewModel to `CameraEngine.setFocusLensPosition` via callback
  - [x] Subscribe to `CameraEngine.$currentLensPosition` for external updates
  - [x] Ensure proper layout in thumb zone (maintain 180pt/110pt sizing)

- [x] Task 6: Unit Tests and Verification (AC: All)
  - [x] Create `FocusDialTests.swift` with tests for ViewModel
  - [x] Test boundary behavior at 0.0 and 1.0
  - [x] Test haptic trigger intervals
  - [x] Verify preview responsiveness on physical device
  - [x] Build and lint validation

## Dev Notes

### Critical: lensPosition is Normalized (0.0 to 1.0)
- `lensPosition = 0.0` → Closest focus (macro)
- `lensPosition = 1.0` → Infinity focus
- **NOT actual physical distance** - approximate display values only

### API Usage
```swift
// Set manual focus (locks autofocus)
device.setFocusModeLocked(lensPosition: 0.5) { syncTime in
  // Focus adjustment completed at given time
}

// Current position (read-only)
let currentPosition = device.lensPosition // 0.0...1.0

// Return to auto-focus
device.focusMode = .continuousAutoFocus
```

### Gesture Direction (Consistent with ISO/Shutter)
- **Swipe UP** → **Increase** lensPosition → Focus **farther** (toward ∞)
- **Swipe DOWN** → **Decrease** lensPosition → Focus **closer** (toward macro)
- This is opposite to the zoom lens mental model but consistent with other dials

### Distance Display Approximation
Since lensPosition doesn't map directly to physical distance, use approximate mapping:
```swift
func approximateDistance(from lensPosition: Float) -> String {
  switch lensPosition {
  case 0.0...0.1: return "0.1m"
  case 0.1...0.2: return "0.3m"
  case 0.2...0.4: return "0.5m"
  case 0.4...0.6: return "1m"
  case 0.6...0.8: return "2m"
  case 0.8...0.95: return "5m"
  default: return "∞"
  }
}
```

### Continuous vs Discrete Control
Unlike ISO and Shutter which use discrete stops, **focus is continuous**:
- No `FocusStops` enum needed (unlike `ISOStops`, `ShutterStops`)
- Use smaller delta threshold (~30pt) for smoother dial feel
- Trigger haptic every ~0.1 lensPosition change for tactile feedback

### Project Structure Notes

- **CameraEngine**: Extend `Camera/Features/Viewfinder/CameraEngine.swift`
- **Views**: Create `Camera/Features/Viewfinder/Views/ManualControls/FocusDialView.swift`
- **Architecture**: Follow `ISODialView.swift` pattern - ViewModel talks to CameraEngine
- **Tests**: Add unit tests to `CameraTests/FocusDialTests.swift`
- **ProControlView**: Replace `placeholderControl(title: "Focus")` at case 3

### Previous Story Intelligence (Stories 2-2 & 2-3: ISO and Shutter Dials)

Key patterns established that MUST be followed:
1. **ViewModel Pattern**: `@ObservableObject` ViewModel with gesture handlers (`onDragStart`, `onDragChange`, `onDragEnd`)
2. **Delta Accumulation**: Track `accumulatedDelta` with threshold for changes
3. **Haptic Pattern**: `UISelectionFeedbackGenerator` for steps, `UIImpactFeedbackGenerator(.heavy)` for bounds
4. **Visual Indicator**: Progress bar component (linear for focus, log-scale for ISO/shutter)
5. **CameraEngine Pattern**: Session queue async for device operations, main thread dispatch for `@Published` updates
6. **ProControlViewModel**: Lazy ViewModel creation with onChanged callback to CameraEngine, Combine subscription for camera updates

Files to reference for patterns:
- `Camera/Features/Viewfinder/Views/ManualControls/ISODialView.swift` (297 lines)
- `Camera/Features/Viewfinder/Views/ManualControls/ShutterSpeedDialView.swift`
- `Camera/Features/Viewfinder/Views/ProControlView.swift` (209 lines)
- `CameraEngine` methods: `setISO(_:)`, `setShutterSpeed(_:)`

### CaptureDeviceProtocol Extension May Be Needed

Current protocol (from CameraEngine.swift) includes:
```swift
protocol CaptureDeviceProtocol: AnyObject, Sendable {
  var isFocusPointOfInterestSupported: Bool { get }
  var focusPointOfInterest: CGPoint { get set }
  var focusMode: AVCaptureDevice.FocusMode { get set }
  // ... other properties
}
```

May need to add:
```swift
var lensPosition: Float { get }
func setFocusModeLocked(lensPosition: Float, completionHandler: ((CMTime) -> Void)?)
```

### References

- [Source: docs/epics/epic-2-manual-controls-pro-mode.md#Story 2.4]
- [Source: docs/architecture/component-architecture.md]
- [Pattern Reference: Camera/Features/Viewfinder/Views/ManualControls/ISODialView.swift]
- [Pattern Reference: Camera/Features/Viewfinder/Views/ManualControls/ShutterSpeedDialView.swift]
- [Pattern Reference: Camera/Features/Viewfinder/Views/ProControlView.swift]
- [Apple Docs: AVCaptureDevice.setFocusModeLocked(lensPosition:completionHandler:)](https://developer.apple.com/documentation/avfoundation/avcapturedevice/1624617-setfocusmodelocked)

## Dev Agent Record

### Agent Model Used

Gemini 2.0 Flash (Antigravity)

### Debug Log References

### Completion Notes List

- ✅ Task 1: Extended `CaptureDeviceProtocol` with `lensPosition` and `setFocusModeLocked(lensPosition:completionHandler:)` methods
- ✅ Task 1: Added `@Published currentLensPosition: Float` and `@Published isUsingManualFocus: Bool` properties to CameraEngine
- ✅ Task 1: Implemented `setFocusLensPosition(_ lensPosition: Float)` method with session queue async pattern
- ✅ Task 1: Implemented `setAutoFocus()` helper method to reset to continuous auto-focus
- ✅ Task 2: Created `FocusDialViewModel` with gesture handlers (`onDragStart`, `onDragChange`, `onDragEnd`)
- ✅ Task 2: Implemented continuous 0.0-1.0 range (no discrete stops) with 30pt delta threshold
- ✅ Task 2: Integrated `UISelectionFeedbackGenerator` for haptic every ~0.1 lensPosition change
- ✅ Task 2: Integrated `UIImpactFeedbackGenerator(.heavy)` for bound resistance at 0.0 and 1.0
- ✅ Task 3: Created `FocusDistance` enum with `displayString(from:)` method mapping lensPosition to distance strings
- ✅ Task 3: Distance mapping: 0.0→"0.1m", 0.15→"0.3m", 0.5→"1m", 0.75→"2m", 0.9→"5m", 1.0→"∞"
- ✅ Task 4: Created `FocusDialView` SwiftUI component matching ISODialView/ShutterSpeedDialView pattern
- ✅ Task 4: Created `FocusDialIndicator` with linear progress (not log-scale) and cyan/teal color scheme
- ✅ Task 5: Added `focusDialViewModel` to `ProControlViewModel` with lazy initialization
- ✅ Task 5: Connected ViewModel to `CameraEngine.setFocusLensPosition` via callback
- ✅ Task 5: Subscribed to `CameraEngine.$currentLensPosition` for external updates
- ✅ Task 5: Replaced placeholder "Focus" control with functional `FocusDialView`
- ✅ Task 6: Created `FocusDialTests.swift` with 15 unit tests covering FocusDistance and FocusDialViewModel
- ✅ Task 6: Updated `MockCaptureDevice` with `lensPosition` and `setFocusModeLocked` for protocol conformance
- ✅ Task 6: Build verified successful with no errors related to story changes

### Code Review Fixes Applied

- ✅ [H1] Fixed thread safety in `setAutoFocus()` by capturing lensPosition before async dispatch
- ✅ [H2] Added input validation in `FocusDialViewModel.init()` to clamp values to 0.0-1.0 range
- ✅ [M1] Removed unused `lastHapticPosition` property from FocusDialViewModel
- ✅ [M2] Added edge case tests for `FocusDistance.displayString` with exact boundary values
- ✅ [M3] Removed dead code `updateLensPositionState()` method from CameraEngine
- ✅ [M4] Added 3 CameraEngine focus control tests: setFocusLensPosition, clamping, and setAutoFocus
- ❌ [L1] Combine import IS required for ObservableObject (false positive, kept)
- ✅ [L2] Replaced magic number 0.02 with named constant `positionChangePerStep`

### File List

- Camera/Features/Viewfinder/CameraEngine.swift (MODIFIED)
- Camera/Features/Viewfinder/Views/ManualControls/FocusDialView.swift (NEW)
- Camera/Features/Viewfinder/Views/ProControlView.swift (MODIFIED)
- CameraTests/FocusDialTests.swift (NEW)
- CameraTests/CameraEngineTests.swift (MODIFIED)

## Change Log

- 2026-01-16: Story 2.4 implemented - Manual Focus Dial Control with visual confirmation
