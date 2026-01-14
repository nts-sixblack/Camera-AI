# UI Patterns

## Observable State Management

All managers use Swift 5.9+ `@Observable` macro:

```swift
@Observable
final class CameraPermissionManager {
    var authorizationStatus: AVAuthorizationStatus = .notDetermined
}
```

Views observe these managers directly:

```swift
struct CameraContentView: View {
    @State private var permissionManager = CameraPermissionManager()
    
    var body: some View {
        if permissionManager.isAuthorized {
            // Show viewfinder
        }
    }
}
```

## UIKit Bridge Pattern

Camera preview uses `UIViewRepresentable` to bridge UIKit:

```swift
struct ViewfinderView: UIViewRepresentable {
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer = CameraEngine.shared.previewLayer
        return view
    }
}
```

---
