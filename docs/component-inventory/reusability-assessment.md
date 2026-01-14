# Reusability Assessment

| Component | Reusable | Notes |
|-----------|----------|-------|
| `PermissionDeniedView` | ✅ Yes | Generic with customizable message |
| `ViewfinderView` | ⚠️ Partial | Tied to CameraEngine singleton |
| `AppColors` | ✅ Yes | Pure color definitions |
| `CameraEngine` | ❌ No | Singleton, app-specific |
