# Story 1.7: Mode Persistence Between Sessions

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **returning user**,
I want **the app to remember my last shooting mode (Auto vs Pro)**,
so that **I don't have to reconfigure my preferred mode every time I launch the app**.

## Acceptance Criteria

### AC1: Restore Last Used Mode
**Given** the user was in Auto mode when the app was closed
**When** the app is launched again
**Then** the app starts in Auto mode (FR16)

### AC2: Restore Pro Mode
**Given** the user was in Pro mode when the app was closed
**When** the app is launched again
**Then** the app starts in Pro mode with the manual control interface visible

### AC3: First Launch Default
**Given** this is the first app launch (no stored preference)
**When** the app opens
**Then** Auto mode is the default state

### AC4: Reactive UI Updates
**Given** the mode is changed during a session
**Then** the preference is saved immediately and persistently
**And** any other parts of the app that observe the mode state update reactively

## Tasks / Subtasks

- [x] Task 1: Implement Persistence Service (AC: #1, #2, #4)
  - [x] Use `UserDefaults` injection (via `@AppStorage` or direct) in the `CameraViewModel` (or equivalent) to track the `lastShootingMode` for testability
  - [x] Define a clear key (e.g., `"com.camera.lastShootingMode"`)
- [x] Task 2: Integration with App Launch (AC: #1, #2, #3)
  - [x] Ensure the stored mode is read and applied during the initial setup of the `CameraEngine`
  - [x] If Pro mode is restored, ensure the `CameraEngine` does NOT reset to auto immediately
- [x] Task 3: Handle App Lifecycle Events (AC: #1, #2)
  - [x] Verify persistence works across force quits and system-initiated background terminations
- [x] Task 4: Write Persistence Tests (NFR6)
  - [x] Test the saving and loading of the mode state using `UserDefaults` (with a test suite domain)
  - [x] Verify the default value logic for first-time launch

- [ ] Review Follow-ups (AI)
  - [ ] [AI-Review][Medium] Verify Engine State: Confirm `CameraEngine` defaults align with Pro mode restoration expectation. [ViewfinderContainerView.swift]
  - [ ] [AI-Review][Medium] UI Verification: Add manual verification for Pro controls validity. [ViewfinderContainerView.swift]

## Dev Notes

### Technical Implementation Details

**SwiftUI Persistence with @AppStorage:**
Using `@AppStorage` allows for easy binding of a property to `UserDefaults`.

```swift
@MainActor
class CameraViewModel: ObservableObject {
    @AppStorage("lastShootingMode") var storedMode: CameraMode = .auto

    // This property can be used to drive the UI
    @Published var currentMode: CameraMode = .auto

    init() {
        // Initialize currentMode from storedMode
        self.currentMode = storedMode
    }

    func toggleMode() {
        currentMode = (currentMode == .auto) ? .pro : .auto
        storedMode = currentMode // Persist immediately
    }
}
```

### Architecture Compliance

| Requirement | Implementation |
|-------------|----------------|
| **NFR16: Persistence** | Last used mode must be restored between sessions. |
| **Simplicity** | Use `@AppStorage` for lightweight persistence of single values. |
| **Performance** | Mode restoration must be near-instant and not block the launch sequence. |

### Project Structure Notes

```
Camera/
├── App/
│   └── CameraViewModel.swift (Update)
└── Features/
    └── Persistence/
        └── SettingsStore.swift # (Optional) If we want a dedicated store later
```

### Previous Story Intelligence (Story 1.3 & 1.6)
- The launch sequence in Story 1.3 should now take the persisted mode into account.
- The toggle from Story 1.6 will now trigger the save operation.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.7]
- [Source: _bmad-output/planning-artifacts/prd.md#App State & Settings]
- [Apple Docs: AppStorage](https://developer.apple.com/documentation/swiftui/appstorage)

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent)

### Debug Log References

### Completion Notes List

### File List

- Camera/Features/Viewfinder/Views/ViewfinderContainerView.swift
- CameraTests/CameraModeTests.swift
