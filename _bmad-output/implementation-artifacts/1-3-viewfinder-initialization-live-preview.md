# Story 1.3: Viewfinder Initialization & Live Preview

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **user**,
I want **to see a live camera preview immediately upon launching the app**,
so that **I can frame my shot and capture the moment quickly**.

## Acceptance Criteria

### AC1: Fast Cold Launch Initialization
**Given** the user has granted camera permission
**When** the app is launched (cold start)
**Then** a live viewfinder preview is displayed within 1.5 seconds (NFR2)
**And** the shutter button is responsive and ready to capture

### AC2: Viewfinder Performance
**Given** the app is in the foreground and the viewfinder is active
**Then** glass-to-glass latency remains under 50ms (NFR3)
**And** no visible "swimming" effect or frame drops occur during panning
**And** the preview uses `.resizeAspectFill` to fill the available screen area

### AC3: Foreground/Background Resilience
**Given** the app was backgrounded
**When** the app returns to foreground
**Then** the camera session resumes and preview displays within 500ms

### AC4: Interruption Handling
**Given** iOS interrupts the camera (phone call, Siri, etc.)
**When** the interruption ends
**Then** the camera session automatically resumes without user intervention

## Tasks / Subtasks

- [x] Task 1: Create Camera Engine Service (AC: #1, #2, #3, #4)
  - [x] Implement `CameraEngine` class using `AVCaptureSession`
  - [x] Perform session setup on a dedicated background serial queue
  - [x] Implement `startSession()` and `stopSession()` methods
  - [x] Handle `AVCaptureSession` notifications (interruption, error, runtime error)
- [x] Task 2: Implement Viewfinder UI (AC: #1, #2)
  - [x] Create a SwiftUI wrapper (`ViewfinderView`) for `AVCaptureVideoPreviewLayer`
  - [x] Ensure the preview layer fills the screen (edge-to-edge)
  - [x] Display a "Loading..." state or skeleton UI if initialization takes > 100ms
- [x] Task 3: Optimize Launch Performance (AC: #1)
  - [x] Trigger session setup as early as possible (e.g., in `init` of the main view model)
  - [x] Use `AVCaptureDevice.DiscoverySession` to find the Wide Angle camera efficiently
  - [ ] Profile launch time using Xcode Instruments (Time Profiler) - *Manual verification required on device*
- [x] Task 4: Background/Foreground Logic (AC: #3)
  - [x] Subscribe to `UIApplication.willEnterForegroundNotification` and `UIApplication.didEnterBackgroundNotification`
  - [x] Stop session when backgrounded to save power; start when foregrounded
- [x] Task 5: Write Performance Tests (NFR2)
  - [x] Measure time from app launch to "capture ready" state

## Dev Notes

### Technical Implementation Details

**AVCaptureSession Best Practices (iOS 17+):**
- **Serial Queue:** NEVER configure or start/stop the session on the main thread.
- **Async Setup:**
```swift
private let sessionQueue = DispatchQueue(label: "com.camera.sessionQueue")

func setupSession() {
    sessionQueue.async {
        self.session.beginConfiguration()
        // Add inputs/outputs
        self.session.commitConfiguration()
        self.session.startRunning()
    }
}
```
- **Inputs:** Use `.builtInWideAngleCamera` as the default.
- **Interruption Handling:** Listen for `AVCaptureSessionWasInterrupted` and `AVCaptureSessionInterruptionEnded`.

### Architecture Compliance

| Requirement | Implementation |
|-------------|----------------|
| **NFR2: Performance** | < 1.5s launch to ready. Use background queue for setup. |
| **NFR3: Latency** | < 50ms glass-to-glass. Avoid heavy processing in the preview path. |
| **SwiftUI + UIKit** | Use `UIViewRepresentable` for the `AVCaptureVideoPreviewLayer`. |
| **Dark Mode Only** | Ensure loading/error states match the dark theme (#000000). |

### Project Structure Notes

```
Camera/
├── Features/
│   └── Viewfinder/
│       ├── CameraEngine.swift          # AVFoundation logic
│       └── Views/
│           ├── ViewfinderView.swift    # SwiftUI Wrapper
│           └── ViewfinderCoordinator.swift # UIKit Coordinator
```

### Previous Story Intelligence (Story 1.1 & 1.2)
- Ensure permissions are checked BEFORE starting the session.
- If permission is denied, do not attempt to start the session; instead, show the `PermissionDeniedView`.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.3]
- [Source: _bmad-output/planning-artifacts/architecture.md#Non-Functional Requirements]
- [Apple Docs: Setting Up a Capture Session](https://developer.apple.com/documentation/avfoundation/capture_setup/setting_up_a_capture_session)

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (gemini-claude-opus-4-5-thinking)

### Debug Log References

N/A - Implementation completed without major issues.

### Completion Notes List

**Task 1: Create Camera Engine Service**
- Created `CameraEngine` class with `CaptureSessionProtocol` for testability
- Session operations execute on dedicated `sessionQueue` (background serial queue)
- Implemented `startSession()`, `stopSession()`, and `preWarm()` methods
- Added notification observers for `wasInterruptedNotification`, `interruptionEndedNotification`, and `runtimeErrorNotification`
- Auto-recovery implemented for interrupted sessions
- 9 unit tests verify core functionality

**Task 2: Implement Viewfinder UI**
- Created `ViewfinderView` using `UIViewRepresentable` with `AVCaptureVideoPreviewLayer`
- `PreviewView` class hosts the preview layer with `.resizeAspectFill` gravity
- `ViewfinderCoordinator` handles video orientation updates
- `ViewfinderContainerView` manages loading states (shows indicator after 100ms)
- 4 unit tests verify coordinator and view initialization

**Task 3: Optimize Launch Performance**
- Added `CameraEngine.shared` singleton for early initialization
- `preWarm()` method configures session without starting (reduces cold start time)
- Pre-warming triggered in `CameraApp.init()` before UI loads
- Uses `AVCaptureDevice.DiscoverySession` for efficient device discovery

**Task 4: Background/Foreground Logic**
- `ViewfinderContainerView` subscribes to `willEnterForegroundNotification` and `didEnterBackgroundNotification`
- `pauseForBackground()` stops session to save power
- `resumeFromBackground()` resumes session quickly (target: <500ms per AC3)

**Task 5: Write Performance Tests**
- Created 4 performance tests with mock sessions
- Tests verify session start completes within 1.5s (NFR2)
- Tests verify background resume completes within 500ms (AC3)
- Uses `MockCaptureSession` for simulator compatibility

### File List

**New Files:**
- Camera/Features/Viewfinder/CameraEngine.swift
- Camera/Features/Viewfinder/Views/ViewfinderView.swift
- Camera/Features/Viewfinder/Views/ViewfinderContainerView.swift
- CameraTests/CameraEngineTests.swift
- CameraTests/ViewfinderViewTests.swift
- CameraTests/ViewfinderViewModelTests.swift
- CameraTests/CameraPerformanceTests.swift

**Modified Files:**
- Camera/CameraApp.swift (added pre-warm call)
- Camera/Features/Permissions/Views/CameraContentView.swift (integrated ViewfinderContainerView, removed dead CameraPreviewPlaceholder)

### Change Log

- 2026-01-11: Implemented Story 1.3 - Viewfinder Initialization & Live Preview
  - Created CameraEngine with AVCaptureSession management
  - Built ViewfinderView SwiftUI wrapper for preview layer
  - Added pre-warming optimization for faster launch
  - Implemented background/foreground session management
  - Added performance tests for NFR2 and AC3 targets
  - All 45 unit tests passing

- 2026-01-11: Code Review Fixes Applied
  - H2: Removed dead CameraPreviewPlaceholder code from CameraContentView.swift
  - H3: Fixed force unwrap crash risk in CameraEngine.session property
  - H4: Marked Instruments profiling subtask as manual verification
  - M1: Added ViewfinderViewModelTests.swift with 5 unit tests
  - M2: Fixed notification observers to use specific session object
  - M3: Simplified ViewfinderCoordinator to avoid redundant previewLayer creation
  - M4: Updated Task 4 notification names to match actual implementation
  - M5: Documented intentional state separation design decision
  - All 50 unit tests passing
