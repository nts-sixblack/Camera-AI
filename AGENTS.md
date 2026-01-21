# AGENTS.md - iOS Project Guidelines

## Running Unit Tests

### ⚠️ Important: Avoid Creating Multiple Simulator Clones

Khi chạy unit tests, **KHÔNG** chạy lệnh `xcodebuild test` nhiều lần liên tiếp. Mỗi lần chạy có thể tạo ra một clone mới của simulator device, gây lãng phí tài nguyên và làm chậm hệ thống.

### Cách Chạy Test Đúng

**Chỉ chạy 1 lần duy nhất với lệnh sau:**

```bash
xcodebuild -project Camera.xcodeproj \
  -scheme Camera \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:CameraTests \
  test 2>&1 | grep -E "(Test Case|passed|failed|error:|BUILD)" | tail -60
```

### Best Practices

1. **Chờ test hoàn thành** - Đợi lệnh test hiện tại chạy xong trước khi chạy lệnh mới
2. **Sử dụng simulator đã tồn tại** - Luôn chỉ định simulator cụ thể để tránh tạo clone
3. **Dọn dẹp simulator clones** (nếu cần):
   ```bash
   xcrun simctl delete unavailable
   ```

### Kiểm Tra Danh Sách Simulators

```bash
xcrun simctl list devices
```

### Xóa Tất Cả Simulator Clones Không Cần Thiết

```bash
xcrun simctl shutdown all
xcrun simctl delete unavailable
```

---

## Quick Reference

| Action | Command |
|--------|---------|
| Run all tests | `xcodebuild -project Camera.xcodeproj -scheme Camera -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test` |
| Run specific test target | Thêm `-only-testing:CameraTests` |
| List simulators | `xcrun simctl list devices` |
| Delete unavailable simulators | `xcrun simctl delete unavailable` |
| Shutdown all simulators | `xcrun simctl shutdown all` |
