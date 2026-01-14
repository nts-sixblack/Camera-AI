# Testing

## Running Unit Tests

**In Xcode:**
```
⌘ + U  (Run All Tests)
```

**From Command Line:**
```bash
xcodebuild test \
  -project Camera.xcodeproj \
  -scheme Camera \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:CameraTests
```

## Running UI Tests

```bash
xcodebuild test \
  -project Camera.xcodeproj \
  -scheme Camera \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:CameraUITests
```

## Running Performance Tests

Performance tests are in `CameraTests/CameraPerformanceTests.swift`:

```bash
xcodebuild test \
  -project Camera.xcodeproj \
  -scheme Camera \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:CameraTests/CameraPerformanceTests
```

## Test Files

| Test File | Coverage |
|-----------|----------|
| `CameraTests.swift` | Basic app tests |
| `CameraEngineTests.swift` | Camera engine unit tests |
| `CameraPerformanceTests.swift` | Performance benchmarks |
| `CameraPermissionManagerTests.swift` | Permission logic |
| `PhotoLibraryPermissionManagerTests.swift` | Photo library permissions |
| `ViewfinderViewModelTests.swift` | Viewfinder ViewModel |
| `ViewfinderViewTests.swift` | Viewfinder View behavior |

---
