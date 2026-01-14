# Debugging

## Common Issues

### Camera Not Working in Simulator

**Solution:** Use a physical device. Camera APIs require real hardware.

### Permission Denied

**Solution:** Reset permissions in Settings or delete/reinstall the app:
```
Settings → General → Transfer or Reset iPhone → Reset → Reset Location & Privacy
```

### Build Signing Error

**Solution:** 
1. Ensure you have a valid Apple Developer account
2. Check Signing & Capabilities in Xcode
3. Verify your device is registered in your developer account

## Debug Tools

- **Xcode Instruments**: Profile camera performance
- **Memory Graph Debugger**: Check for leaks (⌘ + Shift + B while debugging)
- **View Hierarchy Debugger**: Inspect SwiftUI views

---
