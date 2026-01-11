# Story 1.2: Photo Library Permission Request Flow

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **user capturing photos**,
I want **the app to request Photo Library write access with a clear explanation**,
so that **my captured photos are saved to my Camera Roll**.

## Acceptance Criteria

### AC1: First Save Permission Request
**Given** the user attempts to save a captured photo for the first time
**When** Photo Library permission has not been granted (`.notDetermined`)
**Then** a system permission dialog is presented explaining photos will be saved to the Camera Roll (FR17)
**And** the dialog uses the custom usage description from Info.plist

### AC2: Full Access Granted Flow
**Given** the user grants full Photo Library access
**When** the permission is confirmed
**Then** subsequent saves occur without prompts (FR14)
**And** the app continues the save operation that triggered the prompt

> **Integration Note:** The "continues the save operation" behavior will be fully implemented in Story 1.5 (Basic Photo Capture). This story establishes the permission infrastructure; the actual save continuation will be wired up when capture functionality exists.

### AC3: Limited Access Handling (iOS 14+)
**Given** the user grants "Limited Access"
**When** the permission state is `.limited`
**Then** the app functions correctly for saving new photos (NFR9)
**And** no "Select More Photos" system UI is shown unless explicitly requested (unlikely for capture-only app)

### AC4: Permission Denied Flow
**Given** the user denies Photo Library permission
**When** the denial is confirmed
**Then** the app displays an inline explanation screen with an "Open Settings" button (FR18)
**And** tapping the button opens the iOS Settings app directly to the Camera app's permission page

### AC5: Previously Denied State
**Given** the user has previously denied permission
**When** they attempt to capture/save again
**Then** the app displays the permission-denied state with Settings redirect (no repeated system prompts)

## Tasks / Subtasks

- [x] Task 1: Configure Info.plist with Photo Library Usage Description (AC: #1)
  - [x] Add `NSPhotoLibraryAddUsageDescription` key (Write-only is preferred for privacy)
  - [x] Ensure explanation is clear and concise
- [x] Task 2: Implement Photo Library Permission Manager (AC: #1, #2, #3, #4, #5)
  - [x] Create `PhotoLibraryPermissionManager` in `Features/Permissions/`
  - [x] Implement `checkAuthorizationStatus()` using `PHPhotoLibrary.authorizationStatus(for: .addOnly)`
  - [x] Implement `requestAccess()` async method using `PHPhotoLibrary.requestAuthorization(for: .addOnly)`
- [x] Task 3: Create Photo Library Denied View (AC: #4, #5)
  - [x] Design SwiftUI view matching the dark theme established in Story 1.1
  - [x] Include "Open Settings" button with 44x44pt minimum touch target
- [x] Task 4: Integrate with Capture Flow (AC: #1, #2)
  - [x] Update `CameraApp.swift` or relevant coordinator to check both Camera and Photo Library permissions
  - [x] Ensure capture is still possible if Photo Library is denied (but saving is skipped/warned)
- [x] Task 5: Write Unit Tests (NFR6)
  - [x] Test all `PHAuthorizationStatus` states
  - [x] Test logic for showing the denied UI

## Dev Notes

### Technical Implementation Details

**Core API Usage (iOS 17+ Best Practices):**
```swift
import Photos

// Check status (Add-only is preferred for capture apps)
let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)

// Request authorization
let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)

// States:
// .notDetermined: Prompt needed
// .authorized: Full access
// .limited: Limited access (can still save new assets)
// .denied / .restricted: Show Settings redirect
```

**Info.plist Requirement:**
```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Camera needs permission to save photos you take to your library.</string>
```

### Architecture Compliance

| Requirement | Implementation |
|-------------|----------------|
| **Swift 6.x** | Use `async/await` for permission requests |
| **Privacy First** | Use `.addOnly` access to minimize requested permissions (App Store Compliance) |
| **Dark Mode Only** | Background `#000000`, Text `#FFFFFF` |
| **Offline-first** | No network calls needed |
| **Performance** | Permission check must not block UI thread |

### Project Structure Notes

```
Camera/
├── Features/
│   └── Permissions/
│       ├── PhotoLibraryPermissionManager.swift
│       └── Views/
│           └── PhotoLibraryPermissionDeniedView.swift
├── Theme/
│   └── AppColors.swift (centralized color constants)
├── Resources/
│   └── Info.plist (Update)
└── Tests/
    └── PermissionsTests/
        └── PhotoLibraryPermissionManagerTests.swift
```

### Previous Story Intelligence (Story 1.1)
- The developer used `CameraPermissionManager` in `Features/Permissions/`.
- The pattern for `PermissionDeniedView` was established: True Black background, White text, Signal Orange accent for buttons.
- Follow the same routing logic in `CameraApp.swift`.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.2]
- [Source: _bmad-output/planning-artifacts/architecture.md#Technical Constraints]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Color System]
- [Apple Docs: PHPhotoLibrary.requestAuthorization(for:handler:)](https://developer.apple.com/documentation/photokit/phphotolibrary/3616052-requestauthorization)

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5

### Debug Log References

No issues encountered during implementation.

### Completion Notes List

- **Task 1 Completed:** Added `INFOPLIST_KEY_NSPhotoLibraryAddUsageDescription` to project.pbxproj build settings for both Debug and Release configurations. Message: "Camera needs permission to save photos you take to your library."

- **Task 2 Completed:** Created `PhotoLibraryPermissionManager.swift` following the same patterns established in Story 1.1:
  - `PhotoLibraryAuthorizationState` enum with all 5 states (notDetermined, authorized, limited, denied, restricted)
  - `PhotoLibraryPermissionManaging` protocol for testability
  - `PhotoLibraryAuthorizing` wrapper protocol for PHPhotoLibrary static methods
  - Uses `.addOnly` access level for privacy-first approach (App Store compliant)
  - Fully async/await implementation
  - Documented `@unknown default` handling for future-proofing

- **Task 3 Completed:** Created `PhotoLibraryPermissionDeniedView.swift` matching the dark theme from Story 1.1:
  - True Black (#000000) background
  - White text with 0.8 opacity for description
  - Signal Orange (#FF9500) accent color for "Open Settings" button
  - 44x44pt minimum touch target for accessibility
  - VoiceOver accessibility labels
  - Separate states for denied vs restricted

- **Task 4 Completed:** Updated `CameraContentView.swift` to handle both camera and photo library permissions:
  - Added `PermissionBlocker` enum to track which permission is blocking
  - Camera permission takes priority (can't capture without it)
  - Photo Library denied/restricted shows dedicated denied view
  - Limited access allows normal camera operation (with indicator)
  - VoiceOver announcements for both permission state changes
  - Refreshes both permissions when returning from Settings

- **Task 5 Completed:** Created `PhotoLibraryPermissionManagerTests.swift` with comprehensive tests:
  - Tests for all 5 `PHAuthorizationStatus` states mapping correctly
  - Tests for `requestAccess()` returning correct states (authorized, limited, denied, restricted)
  - Tests verifying `.addOnly` access level is used
  - Tests for `PhotoLibraryAuthorizationState` Equatable conformance
  - Tests for Settings URL validity
  - View logic tests for denied/restricted state handling

All 28 tests passing.

### File List

**New Files:**
- Camera/Features/Permissions/PhotoLibraryPermissionManager.swift
- Camera/Features/Permissions/Views/PhotoLibraryPermissionDeniedView.swift
- Camera/Theme/AppColors.swift
- CameraTests/PhotoLibraryPermissionManagerTests.swift

**Modified Files:**
- Camera.xcodeproj/project.pbxproj (added NSPhotoLibraryAddUsageDescription)
- Camera/Features/Permissions/Views/CameraContentView.swift (integrated photo library permission flow)
- Camera/Features/Permissions/Views/PermissionDeniedView.swift (refactored to use AppColors)

## Change Log

| Date | Change |
|------|--------|
| 2026-01-09 | Implemented Photo Library permission request flow with all 5 acceptance criteria satisfied. Added PhotoLibraryPermissionManager, PhotoLibraryPermissionDeniedView, integrated with CameraContentView, and comprehensive unit tests. All 22 tests passing. |
| 2026-01-09 | **Code Review Fixes:** Added missing test for restricted state in requestAccess(), added view logic tests (5 new tests), extracted shared AppColors.swift to eliminate duplicate color constants, added documentation for @unknown default handling. Total: 28 tests passing. |
