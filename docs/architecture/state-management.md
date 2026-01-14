# State Management

## Observable Pattern

All managers use `@Observable` macro (iOS 17+) for SwiftUI integration:

```swift
@Observable
final class CameraPermissionManager {
    var authorizationStatus: AVAuthorizationStatus
    var isAuthorized: Bool { authorizationStatus == .authorized }
}
```

## State Persistence

Per PRD requirement FR16, shooting mode persists between sessions:
- **Storage:** UserDefaults
- **Key:** Last used mode (Auto/Manual)

---
