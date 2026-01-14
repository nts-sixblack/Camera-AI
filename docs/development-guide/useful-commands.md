# Useful Commands

```bash
# Clean build folder
xcodebuild clean -project Camera.xcodeproj -scheme Camera

# Show available destinations
xcodebuild -project Camera.xcodeproj -scheme Camera -showdestinations

# Run static analysis
xcodebuild analyze -project Camera.xcodeproj -scheme Camera

# Generate code coverage report
xcodebuild test -project Camera.xcodeproj -scheme Camera \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -enableCodeCoverage YES
```
