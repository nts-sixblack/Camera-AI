# Building

## Development Build

```bash
# Build for development
xcodebuild build \
  -project Camera.xcodeproj \
  -scheme Camera \
  -configuration Debug \
  -destination 'platform=iOS,name=Your iPhone'
```

## Release Build

```bash
# Build for release
xcodebuild build \
  -project Camera.xcodeproj \
  -scheme Camera \
  -configuration Release \
  -destination 'generic/platform=iOS'
```

---
