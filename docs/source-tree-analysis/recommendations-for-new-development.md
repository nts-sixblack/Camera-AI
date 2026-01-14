# Recommendations for New Development

When adding new features:

1. Create a new directory under `Camera/Features/{FeatureName}/`
2. Add manager/service files at the feature root
3. Add views in a `Views/` subdirectory
4. Add corresponding tests in `CameraTests/`
5. Update `CameraContentView.swift` to integrate the new feature
