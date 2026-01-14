# Performance Architecture

## Critical Performance Requirements

| Metric | Target | Strategy |
|--------|--------|----------|
| Cold launch to capture | < 1.5s | CameraEngine.preWarm() on init |
| Viewfinder latency | < 50ms | Metal-based preview pipeline |
| UI responsiveness | 60 FPS | Async camera operations |
| RAW burst capture | 10 FPS for 3s | Buffer pool management |

## Thermal Management

The app monitors thermal state and degrades gracefully:
1. **Nominal:** Full functionality
2. **Fair:** Reduce preview frame rate
3. **Serious:** Pause background processing
4. **Critical:** Stop capture, show warning

## Memory Management

- Pre-allocated buffer pools for RAW capture
- Aggressive release of processed buffers
- Memory pressure monitoring

---
