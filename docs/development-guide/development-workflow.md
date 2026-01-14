# Development Workflow

## Feature Development

1. **Check Sprint Status**: Review `_bmad-output/implementation-artifacts/sprint-status.yaml`
2. **Find Story**: Look for stories in `ready-for-dev` status
3. **Read Requirements**: Open the story file in `implementation-artifacts/`
4. **Implement**: Follow story acceptance criteria
5. **Test**: Write unit tests in `CameraTests/`
6. **PR**: Create pull request for review

## Creating New Features

New features should follow the established pattern:

```bash
# Create feature directory structure
mkdir -p Camera/Features/NewFeature/Views
```

Create required files:
- `Camera/Features/NewFeature/NewFeatureManager.swift` - Business logic
- `Camera/Features/NewFeature/Views/NewFeatureView.swift` - UI

## Code Style

- **Swift 6.x** with strict concurrency checking
- **SwiftUI** for all new UI components
- **MVVM** pattern for complex views
- **@Observable** macro for state management

---
