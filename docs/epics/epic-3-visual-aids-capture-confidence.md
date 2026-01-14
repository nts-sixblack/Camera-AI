# Epic 3: Visual Aids & Capture Confidence

Users can enable histogram and focus peaking overlays, and lock exposure/focus independently to confirm their shot before capture.

## Story 3.1: Real-Time RGB Histogram Overlay

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

## Story 3.2: Focus Peaking Overlay

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

## Story 3.3: Independent AE Lock (Auto Exposure Lock)

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

## Story 3.4: Independent AF Lock (Auto Focus Lock)

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

## Story 3.5: Combined AE/AF Lock Gesture

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

## Story 3.6: Visual Aid Toggle Controls

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
