# Core User Experience

## Defining Experience

The core experience of Camera centers on **the dial interaction**—swipe-based manual controls for ISO, Shutter Speed, Focus, and White Balance. This is the signature interaction that differentiates Camera from the native app. When a user swipes a dial and feels the haptic feedback while watching the preview respond in real-time, they experience the "aha" moment: professional control in their pocket.

**Core User Action:** Capture a photo with intentional, manually-controlled settings.

**Critical Interaction:** The manual control dials must feel physical and precise—like turning a real camera dial—with immediate visual feedback and tactile haptic "clicks."

## Platform Strategy

- **Platform:** Native iOS application (iPhone only)
- **Framework:** Swift/SwiftUI + AVFoundation/Metal for maximum performance
- **Input:** Touch-first with gesture-based controls
- **Connectivity:** 100% offline functionality, no account required
- **Device Capabilities:** Haptic Engine for dial feedback, ProRAW support, multi-lens switching, thermal monitoring

## Effortless Interactions

| Interaction | Expected Behavior |
|-------------|-------------------|
| Manual Dials | Swipe gestures feel like physical wheels—responsive, precise, haptic clicks |
| Mode Toggle | One tap to flip Auto ↔ Pro—instant, no confirmation |
| Capture | Shutter always thumb-reachable, zero delay tap-to-capture |
| Focus | Tap anywhere on viewfinder to set focus point |
| Lens Switch | Single tap to cycle through available lenses |

## Critical Success Moments

1. **"This is better" moment:** User swipes exposure dial, preview darkens in real-time with haptic feedback—instant confirmation of control
2. **First-time success:** New user opens app, sees familiar viewfinder, taps Pro, immediately grasps dial system without tutorial
3. **Make-or-break flow:** Adjust settings → Capture → Review shows shot matches preview exactly

## Experience Principles

1. **Dials Are King** - The swipe-dial interaction defines the product; it must feel physical and precise
2. **Instant Feedback** - Every adjustment shows immediately in the preview; no lag, no guessing
3. **One-Tap Escapes** - Auto mode is always one tap away; complexity never traps users
4. **Trust the Preview** - What you see is what you capture; the viewfinder is truth
