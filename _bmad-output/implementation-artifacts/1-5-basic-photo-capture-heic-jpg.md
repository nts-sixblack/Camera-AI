# Story 1.5: Basic Photo Capture (HEIC/JPG)

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **user**,
I want **to tap the shutter button to capture a photo in HEIC or JPG format**,
so that **I can preserve the moment in a standard image format**.

## Acceptance Criteria

### AC1: Immediate Capture Initiation
**Given** the viewfinder is active and permissions are granted
**When** the user taps the shutter button
**Then** a photo capture is initiated immediately
**And** a brief flash animation occurs on the viewfinder
**And** medium haptic feedback is triggered

### AC2: HEIC/JPG Format Handling
**Given** the device supports HEIC (High Efficiency)
**When** a photo is captured
**Then** the image is processed and saved in HEIC format (FR13)
**And** if HEIC is not supported, the app falls back to JPG automatically

### AC3: Saving to Photo Library
**Given** a photo capture completes successfully
**When** the image data is ready
**Then** the image is saved to the device's main Photo Library (FR14)
**And** all relevant metadata (EXIF, orientation) is preserved

### AC4: Viewfinder Continuity
**Given** a photo is being captured/saved
**Then** the viewfinder remains active and responsive (no freezing)
**And** the user can capture another photo as soon as the flash animation finishes

## Tasks / Subtasks

- [x] Task 1: Update Camera Engine with Photo Output (AC: #1, #2)
  - [x] Add `AVCapturePhotoOutput` to the `AVCaptureSession`
  - [x] Implement `capturePhoto()` method
  - [x] Configure `AVCapturePhotoSettings` for HEIC (with JPG fallback)
- [x] Task 2: Implement Photo Capture Delegate (AC: #1, #2, #3)
  - [x] Create `PhotoCaptureProcessor` (conforming to `AVCapturePhotoCaptureDelegate`)
  - [x] Handle `didFinishProcessingPhoto` callback
  - [x] Extract file data representation using `photo.fileDataRepresentation()`
- [x] Task 3: Implement Shutter Button & Feedback (AC: #1)
  - [x] Create SwiftUI `ShutterButtonView` (Large white ring/circle in the thumb zone)
  - [x] Implement the viewfinder "flash" overlay animation
  - [x] Trigger `UIImpactFeedbackGenerator(style: .medium)` on tap
- [x] Task 4: Implement Photo Library Persistence (AC: #3)
  - [x] Create `PhotoPersistenceService` to handle `PHPhotoLibrary` writes
  - [x] Save the captured data using `PHAssetCreationRequest`
- [x] Task 5: Write Integration Tests (NFR6)
  - [x] Test the capture request flow (Unit + Manual)
  - [x] Verify format selection logic (Code Review)

## Dev Notes

### Technical Implementation Details

**Capture Settings Configuration:**
```swift
func capturePhoto() {
    let photoSettings: AVCapturePhotoSettings
    if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
        photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
    } else {
        photoSettings = AVCapturePhotoSettings()
    }

    // Request the capture
    photoOutput.capturePhoto(with: photoSettings, delegate: self)
}
```

**Saving to Library:**
```swift
func saveToLibrary(data: Data) {
    PHPhotoLibrary.shared().performChanges {
        let request = PHAssetCreationRequest.forAsset()
        request.addResource(with: .photo, data: data, options: nil)
    } completionHandler: { success, error in
        // Handle success/failure
    }
}
```

### Architecture Compliance

| Requirement | Implementation |
|-------------|----------------|
| **UX Consistency** | Viewfinder flash (white overlay with 0.1s opacity animation). |
| **Performance** | Capture must not block the main thread or freeze the viewfinder. |
| **Asset Management** | Use `PHPhotoLibrary` for native iOS integration. |

### Project Structure Notes

```
Camera/
├── Features/
│   ├── Viewfinder/
│   │   └── CameraEngine.swift (Update)
│   └── Capture/
│       ├── PhotoCaptureProcessor.swift # Delegate implementation
│       ├── PhotoPersistenceService.swift # Library saving logic
│       └── Views/
│           └── ShutterButtonView.swift
```

### Previous Story Intelligence (Story 1.2 & 1.3)
- Ensure Photo Library permission has been granted before attempting to save.
- Use the `CameraEngine` established in Story 1.3 to add the `AVCapturePhotoOutput`.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.5]
- [Source: _bmad-output/planning-artifacts/architecture.md#Functional Requirements]
- [Apple Docs: Capturing Photos](https://developer.apple.com/documentation/avfoundation/capture_setup/capturing_still_and_video_media)

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent)

### Debug Log References

### Completion Notes List
- Implemented `CameraEngine` photo output and capture logic with HEIC preference.
- Created `PhotoCaptureProcessor` to handle delegate callbacks.
- Created `PhotoPersistenceService` to save photos to library.
- Added `ShutterButtonView` with haptic feedback and flash animation in `ViewfinderContainerView`.
- Verified build and unit tests pass.

### File List
- Camera/Features/Viewfinder/CameraEngine.swift
- Camera/Features/Capture/PhotoCaptureProcessor.swift
- Camera/Features/Capture/PhotoPersistenceService.swift
- Camera/Features/Capture/Views/ShutterButtonView.swift
- Camera/Features/Viewfinder/Views/ViewfinderContainerView.swift
- CameraTests/CameraEngineTests.swift

## Senior Developer Review (AI)

_Reviewer: Sixblack on 2026-01-14_
- **Status:** Approved (Auto-Fixed)
- **Critical Issues Fixed:**
    - Handled `videoOrientation` in `CameraEngine.capturePhoto` to ensure photos are not rotated.
- **Medium Issues Fixed:**
    - Added tests for `capturePhoto` non-blocking execution.
    - Added untracked files to git.
- **Outcome:** Code quality improved, basic functionality verified with smoke tests. Ready for merge.
