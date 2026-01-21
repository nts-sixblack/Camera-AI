# Story 2.5: White Balance Control with Presets and Kelvin

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **photographer**,
I want **to select White Balance presets or set a custom Kelvin value**,
so that **I can achieve accurate or intentional color tones in my images**.

## Acceptance Criteria

### AC1: WB Preset Selection
**Given** Pro mode is active and the WB control is selected
**When** the user taps on a preset (Auto, Sunny, Cloudy, Shade, Tungsten, Fluorescent)
**Then** the white balance applies immediately to the preview
**And** the selected preset is visually indicated

### AC2: Custom Kelvin Dial
**Given** the user wants custom white balance
**When** the user swipes on the WB dial
**Then** the Kelvin value changes (range: ~2000K to ~10000K)
**And** the preview color temperature updates in real-time
**And** the current Kelvin value is displayed (e.g., "5500K")

### AC3: Preset Information Display
**Given** a WB preset is selected
**When** displayed
**Then** the preset name and approximate Kelvin value are shown

### AC4: Haptic Feedback
**Given** the user is adjusting Kelvin via dial
**When** the value changes through significant increments (e.g., 100K steps)
**Then** haptic feedback triggers (consistent with other dials)

### AC5: Boundary Resistance
**Given** the Kelvin is at minimum (2000K) or maximum (10000K)
**When** the user attempts to exceed the bound
**Then** resistance feedback triggers and value remains at boundary

## WB Preset Values

| Preset | Approximate Kelvin |
|--------|-------------------|
| Auto | System-managed |
| Sunny | ~5500K |
| Cloudy | ~6500K |
| Shade | ~7500K |
| Tungsten | ~3200K |
| Fluorescent | ~4000K |

## Tasks / Subtasks

- [x] Task 1: Extend CameraEngine for White Balance Control (AC: #1, #2)
  - [x] Add `setWhiteBalanceTemperature(_ kelvin: Float)` method to `CameraEngine`
  - [x] Use `AVCaptureDevice.deviceWhiteBalanceGains(for: temperatureAndTintValues)` to convert Kelvin → gains
  - [x] Use `AVCaptureDevice.setWhiteBalanceModeLocked(with: gains)` to apply
  - [x] Add published properties: `currentTemperatureKelvin: Float`, `isUsingManualWhiteBalance: Bool`
  - [x] Extend `CaptureDeviceProtocol` with white balance temperature/tint methods
  - [x] Add helper method `setAutoWhiteBalance()` to return to auto mode

- [x] Task 2: Create WhiteBalancePreset Enum and Helpers (AC: #1, #3)
  - [x] Create `WhiteBalancePreset` enum with cases: `auto`, `sunny`, `cloudy`, `shade`, `tungsten`, `fluorescent`, `custom`
  - [x] Define `kelvinValue: Float?` property for each preset (nil for auto/custom)
  - [x] Define `displayName: String` property for each preset
  - [x] Define `tintValue: Float` property (default 0.0 for neutral tint)

- [x] Task 3: Create WhiteBalanceDialViewModel (AC: #2, #4, #5)
  - [x] Create `WhiteBalanceDialView.swift` in `Camera/Features/Viewfinder/Views/ManualControls/`
  - [x] Implement `WhiteBalanceDialViewModel` following ISODialViewModel pattern
  - [x] Use continuous range 2000.0...10000.0 for Kelvin
  - [x] Implement delta accumulation with 50K threshold for changes (100K for haptic)
  - [x] Integrate `UISelectionFeedbackGenerator` for step haptics
  - [x] Integrate `UIImpactFeedbackGenerator(.heavy)` for bound resistance at 2000K and 10000K
  - [x] Add preset selection support: `selectPreset(_ preset: WhiteBalancePreset)`
  - [x] Track `selectedPreset: WhiteBalancePreset` state

- [x] Task 4: Create WhiteBalanceDialView UI Component (AC: #1, #2, #3)
  - [x] Create `WhiteBalanceDialView` with dual-mode interface:
    - **Preset Mode**: Horizontal scrollable preset buttons
    - **Custom Mode**: Vertical swipe dial for Kelvin adjustment
  - [x] Display current preset name OR Kelvin value (e.g., "Sunny (5500K)" or "Custom: 6200K")
  - [x] Create `WhiteBalanceDialIndicator` with color temperature gradient visualization
  - [x] Add hint text "Tap preset or swipe ↑↓ for Kelvin"
  - [x] Use warm-to-cool color gradient (orange 2000K → white 6500K → blue 10000K)

- [x] Task 5: Integrate into ProControlView (AC: #1, #2)
  - [x] Replace `placeholderControl(title: "White Balance")` at case 2 with `WhiteBalanceDialView`
  - [x] Add `whiteBalanceDialViewModel` to `ProControlViewModel` following existing patterns
  - [x] Connect ViewModel to `CameraEngine.setWhiteBalanceTemperature` via callback
  - [x] Subscribe to `CameraEngine.$currentTemperatureKelvin` for external updates
  - [x] Handle preset selection → temperature conversion
  - [x] Ensure proper layout in thumb zone (maintain 180pt/110pt sizing)

- [x] Task 6: Unit Tests and Verification (AC: All)
  - [x] Create `WhiteBalanceDialTests.swift` with tests for:
    - WhiteBalancePreset enum values and properties
    - WhiteBalanceDialViewModel preset selection
    - WhiteBalanceDialViewModel Kelvin adjustment within bounds
    - Boundary clamping at 2000K and 10000K
    - Haptic trigger intervals
  - [x] Add CameraEngine tests for white balance temperature setting
  - [x] Update `MockCaptureDevice` with white balance temperature/tint methods
  - [x] Build and lint validation

## Dev Notes

### Critical: AVFoundation White Balance API

**Converting Kelvin to Device Gains:**
```swift
// Create temperature and tint values
let temperatureAndTint = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(
    temperature: 5500,  // Kelvin
    tint: 0.0           // Neutral tint (-150 to +150)
)

// Convert to device-specific gains
let gains = device.deviceWhiteBalanceGains(for: temperatureAndTint)

// Lock white balance with the gains
device.setWhiteBalanceModeLocked(with: gains) { syncTime in
    // White balance adjustment completed
}

// Return to auto white balance
device.whiteBalanceMode = .continuousAutoWhiteBalance
```

### Gain Clamping Required
`deviceWhiteBalanceGains(for:)` may return gains outside the valid range. Always clamp:
```swift
func clampGains(_ gains: AVCaptureDevice.WhiteBalanceGains) -> AVCaptureDevice.WhiteBalanceGains {
    let maxGain = device.maxWhiteBalanceGain
    return AVCaptureDevice.WhiteBalanceGains(
        redGain: max(1.0, min(gains.redGain, maxGain)),
        greenGain: max(1.0, min(gains.greenGain, maxGain)),
        blueGain: max(1.0, min(gains.blueGain, maxGain))
    )
}
```

### CaptureDeviceProtocol Extension Required

Current protocol (from CameraEngine.swift) already includes:
```swift
var whiteBalanceMode: AVCaptureDevice.WhiteBalanceMode { get set }
func isWhiteBalanceModeSupported(_ whiteBalanceMode: AVCaptureDevice.WhiteBalanceMode) -> Bool
```

**Must add:**
```swift
var maxWhiteBalanceGain: Float { get }
func deviceWhiteBalanceGains(for temperatureAndTint: AVCaptureDevice.WhiteBalanceTemperatureAndTintValues) -> AVCaptureDevice.WhiteBalanceGains
func setWhiteBalanceModeLocked(with gains: AVCaptureDevice.WhiteBalanceGains, completionHandler: ((CMTime) -> Void)?)
```

### Gesture Direction (Consistent with Other Dials)
- **Swipe UP** → **Increase** Kelvin → **Cooler** (bluer)
- **Swipe DOWN** → **Decrease** Kelvin → **Warmer** (more orange)

### UI Layout Considerations
Unlike other single-dial controls, WB has **dual-mode interface**:
1. **Preset bar** at top: Horizontal row of tappable preset buttons
2. **Kelvin dial** below: Vertical swipe area for fine-tuning

Option 1: Compact layout fitting in 110pt control height
Option 2: Preset buttons scroll horizontally, Kelvin indicator below

### Color Temperature Visual
Use gradient from warm (orange) to cool (blue):
- 2000K-3200K: Deep orange/amber (candlelight, tungsten)
- 3200K-5500K: Orange to neutral white (sunrise, daylight)
- 5500K-6500K: Neutral white (noon daylight, flash)
- 6500K-10000K: Blue-ish (overcast, shade, blue sky)

### Project Structure Notes

- **CameraEngine**: Extend `Camera/Features/Viewfinder/CameraEngine.swift`
- **Views**: Create `Camera/Features/Viewfinder/Views/ManualControls/WhiteBalanceDialView.swift`
- **Architecture**: Follow `ISODialView.swift` pattern - ViewModel talks to CameraEngine
- **Tests**: Add unit tests to `CameraTests/WhiteBalanceDialTests.swift`
- **ProControlView**: Replace `placeholderControl(title: "White Balance")` at case 2

### Previous Story Intelligence (Stories 2-2, 2-3, 2-4: ISO, Shutter, Focus Dials)

Key patterns established that MUST be followed:
1. **ViewModel Pattern**: `@ObservableObject` ViewModel with gesture handlers (`onDragStart`, `onDragChange`, `onDragEnd`)
2. **Delta Accumulation**: Track `accumulatedDelta` with threshold for changes
3. **Haptic Pattern**: `UISelectionFeedbackGenerator` for steps, `UIImpactFeedbackGenerator(.heavy)` for bounds
4. **Visual Indicator**: Progress bar component with appropriate color scheme
5. **CameraEngine Pattern**: Session queue async for device operations, main thread dispatch for `@Published` updates
6. **ProControlViewModel**: Lazy ViewModel creation with onChanged callback to CameraEngine, Combine subscription for camera updates
7. **Input Validation**: Clamp values in ViewModel init (learned from Story 2-4 code review)
8. **Named Constants**: Avoid magic numbers - use named constants like `positionChangePerStep`
9. **Thread Safety**: Capture values before async dispatch to avoid race conditions

Files to reference for patterns:
- `Camera/Features/Viewfinder/Views/ManualControls/ISODialView.swift` (297 lines)
- `Camera/Features/Viewfinder/Views/ManualControls/ShutterSpeedDialView.swift`
- `Camera/Features/Viewfinder/Views/ManualControls/FocusDialView.swift`
- `Camera/Features/Viewfinder/Views/ProControlView.swift` (228 lines)
- `CameraEngine` methods: `setISO(_:)`, `setShutterSpeed(_:)`, `setFocusLensPosition(_:)`

### Unique Considerations for White Balance

1. **Preset Selection + Custom Dial**: Unlike pure dial controls, WB requires both tap interaction (presets) and swipe (Kelvin)
2. **Preset → Custom Transition**: When user swipes dial, automatically switch to "Custom" preset
3. **Color Temperature Visualization**: Consider gradient indicator from warm to cool colors
4. **Tint Value**: Keep tint at 0.0 (neutral) for simplicity in this story - advanced green/magenta adjustment could be future story

### References

- [Source: docs/epics/epic-2-manual-controls-pro-mode.md#Story 2.5]
- [Pattern Reference: Camera/Features/Viewfinder/Views/ManualControls/ISODialView.swift]
- [Pattern Reference: Camera/Features/Viewfinder/Views/ManualControls/FocusDialView.swift]
- [Pattern Reference: Camera/Features/Viewfinder/Views/ProControlView.swift]
- [Apple Docs: AVCaptureDevice.setWhiteBalanceModeLocked(with:)](https://developer.apple.com/documentation/avfoundation/avcapturedevice/1624568-setwhitebalancemodelocked)
- [Apple Docs: AVCaptureDevice.deviceWhiteBalanceGains(for:)](https://developer.apple.com/documentation/avfoundation/avcapturedevice/1624628-devicewhitebalancegains)

## Dev Agent Record

### Agent Model Used

Gemini 2.0 Flash (Antigravity)

### Debug Log References

### Completion Notes List

- ✅ Task 1: Extended `CaptureDeviceProtocol` with `maxWhiteBalanceGain`, `deviceWhiteBalanceGains(for:)`, and `setWhiteBalanceModeLocked(with:)` methods
- ✅ Task 1: Added `@Published currentTemperatureKelvin: Float` (5500.0 default) and `@Published isUsingManualWhiteBalance: Bool` properties to CameraEngine
- ✅ Task 1: Implemented `setWhiteBalanceTemperature(_ kelvin: Float)` method with gain clamping via `clampWhiteBalanceGains()` helper
- ✅ Task 1: Implemented `setAutoWhiteBalance()` helper method to reset to continuous auto white balance mode
- ✅ Task 2: Created `WhiteBalancePreset` enum with 7 cases (auto, sunny, cloudy, shade, tungsten, fluorescent, custom)
- ✅ Task 2: Implemented `kelvinValue: Float?`, `displayName: String`, `tintValue: Float`, and `shortSymbol: String` properties
- ✅ Task 3: Created `WhiteBalanceDialViewModel` with gesture handlers (`onDragStart`, `onDragChange`, `onDragEnd`)
- ✅ Task 3: Implemented continuous 2000-10000K range with 30pt delta threshold for 100K Kelvin steps
- ✅ Task 3: Integrated `UISelectionFeedbackGenerator` for step haptics and `UIImpactFeedbackGenerator(.heavy)` for bounds
- ✅ Task 3: Added `selectPreset(_ preset:)` method and `selectedPreset` state tracking with `onPresetSelected` callback
- ✅ Task 4: Created `WhiteBalanceDialView` SwiftUI component with dual-mode interface (presets + Kelvin dial)
- ✅ Task 4: Created `WhiteBalanceDialIndicator` with warm-to-cool color gradient (orange → white → blue)
- ✅ Task 4: Added horizontal scrollview with emoji preset buttons and compact display text
- ✅ Task 5: Added `whiteBalanceDialViewModel` to `ProControlViewModel` with lazy initialization
- ✅ Task 5: Connected ViewModel to `CameraEngine.setWhiteBalanceTemperature` and `setAutoWhiteBalance` via callbacks
- ✅ Task 5: Subscribed to `CameraEngine.$currentTemperatureKelvin` for external updates
- ✅ Task 5: Replaced placeholder "White Balance" control with functional `WhiteBalanceDialView`
- ✅ Task 6: Created `WhiteBalanceDialTests.swift` with 20 unit tests covering preset enum and ViewModel
- ✅ Task 6: Added 3 CameraEngine white balance tests: setWhiteBalanceTemperature, clamping, setAutoWhiteBalance
- ✅ Task 6: Updated `MockCaptureDevice` with `maxWhiteBalanceGain`, `deviceWhiteBalanceGains`, `setWhiteBalanceModeLocked` for protocol conformance
- ✅ Task 6: Build verified successful with no errors

### File List

- Camera/Features/Viewfinder/CameraEngine.swift (MODIFIED)
- Camera/Features/Viewfinder/Views/ManualControls/WhiteBalanceDialView.swift (NEW)
- Camera/Features/Viewfinder/Views/ProControlView.swift (MODIFIED)
- Camera/Features/Viewfinder/Views/ViewfinderContainerView.swift (MODIFIED)
- CameraTests/WhiteBalanceDialTests.swift (NEW)
- CameraTests/CameraEngineTests.swift (MODIFIED)

## Change Log

- 2026-01-16: Story 2.5 created - White Balance Control with Presets and Kelvin
- 2026-01-16: Story 2.5 implemented - All tasks complete, build verified, tests created
- 2026-01-21: Adversarial Code Review - Fixed documentation gaps (added ViewfinderContainerView) and strengthened CameraEngineTests for clamping verification.
