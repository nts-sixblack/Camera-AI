# Getting Started

## Prerequisites

- Xcode 15 or later
- iOS 17.0+ deployment target
- Physical iPhone device (required for camera testing)

## Development Setup

1. Open `Camera.xcodeproj` in Xcode
2. Select a physical iOS device as the run destination
3. Build and run (⌘R)

## Running Tests

```bash
# Run unit tests
xcodebuild test -project Camera.xcodeproj -scheme Camera -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run UI tests
xcodebuild test -project Camera.xcodeproj -scheme Camera -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:CameraUITests
```

---
