# Epic 1: Core Camera Foundation & Basic Capture

Users can launch the app, grant permissions, and capture photos in Auto mode with the familiar viewfinder experience.

## Story 1.1: Camera Permission Request Flow

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

## Story 1.2: Photo Library Permission Request Flow

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

## Story 1.3: Viewfinder Initialization & Live Preview

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

## Story 1.4: Tap-to-Focus Interaction

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

## Story 1.5: Basic Photo Capture (HEIC/JPG)

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

## Story 1.6: Auto Mode Toggle

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

## Story 1.7: Mode Persistence Between Sessions

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
