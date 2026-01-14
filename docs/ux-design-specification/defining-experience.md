# Defining Experience

## The Core Interaction

**"Swipe the dial, see it change, capture with confidence"**

The defining experience of Camera is the moment a user swipes to adjust exposure, watches the preview respond in real-time with haptic feedback, and captures exactly what they intended. This is the interaction users will describe to friends and the reason they choose Camera over alternatives.

## User Mental Model

**Expectations users bring:**
- **From DSLR/Mirrorless cameras:** Physical dials that click, WYSIWYG viewfinders, direct control
- **From Native iPhone Camera:** Tap-to-focus, instant capture, reliable results
- **From Halide/ProCamera:** Gesture-based manual controls on mobile

**What they love:** Direct cause-and-effect control, immediate visual feedback, predictable results
**What they hate:** Input lag, unpredictable results, settings buried in menus, captures that don't match preview

## Success Criteria

| Criteria | Target |
|----------|--------|
| Dial response latency | <16ms (60 FPS) |
| Preview-to-capture fidelity | 100% match |
| Time to adjust any setting | <2 seconds |
| Haptic feedback | On every dial "click" |
| Mode switch time | <500ms |
| Launch to capture-ready | <1.5 seconds |

## Pattern Analysis

| Pattern Type | Implementation |
|--------------|----------------|
| **Established** | Tap-to-focus (from native Camera) |
| **Established** | Swipe for mode switching (from native Camera) |
| **Adapted** | Swipe-dial controls (from Halide, refined) |
| **Novel Combination** | Haptic clicks synced with dial values + real-time preview |

**Assessment:** Primarily established patterns combined in a polished way—no user education required. Users familiar with native Camera or Halide will feel instantly at home.

## Experience Mechanics

**The Dial Interaction Flow:**

**1. Initiation**
- User enters Pro mode via visible toggle (always accessible)
- Dial controls appear at bottom of screen (thumb zone)
- Current values displayed: ISO 100 | 1/250s | f/1.8

**2. Interaction**
- User places thumb on dial area (ISO, Shutter, Focus, or WB)
- Swipes up/down to adjust value
- Each "stop" triggers haptic tick
- Preview updates in real-time (<16ms latency)
- Value label updates with current setting

**3. Feedback**
- **Visual:** Preview brightness/exposure changes immediately
- **Haptic:** Subtle tick on each value increment
- **Audio:** Optional soft click (user preference)
- **Confirmation:** Histogram shifts to reflect exposure change

**4. Completion**
- User lifts thumb—value locks in place
- Settings persist until manually changed
- User taps shutter to capture
- Brief flash animation confirms capture
- Image saved matches preview exactly
