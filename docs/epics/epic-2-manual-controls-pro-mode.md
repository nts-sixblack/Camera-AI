# Epic 2: Manual Controls & Pro Mode

Users can switch to Pro mode and manually control ISO, Shutter Speed, Focus, and White Balance with immediate visual feedback.

## Story 2.1: Pro Mode Activation & UI Transition

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

## Story 2.2: ISO Dial Control with Real-Time Preview

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

## Story 2.3: Shutter Speed Dial Control with Real-Time Preview

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

## Story 2.4: Manual Focus Dial Control with Visual Confirmation

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

## Story 2.5: White Balance Control with Presets and Kelvin

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

## Story 2.6: Hardware Lens Switching (Virtual Device)

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

## Story 2.7: Exposure Values Display (HUD)

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
