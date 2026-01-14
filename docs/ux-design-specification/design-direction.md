# Design Direction

## Design Directions Explored

Four design directions were evaluated for Camera's interface approach:

- **Direction A: Halide-Style Minimal** - Ultra-clean viewfinder, horizontal dial strip, controls fade when idle
- **Direction B: Pro Cockpit** - Information-rich with persistent data overlay, vertical dial stack
- **Direction C: Native Camera Evolution** - Familiar native layout with progressive complexity
- **Direction D: Split View** - Dedicated control panel separated from viewfinder

## Chosen Direction

**Direction A: Halide-Style Minimal**

A clean, viewfinder-first approach where the image is always the hero. Controls live in a horizontal dial strip at the bottom, fading to near-invisibility when not in use. This direction maximizes screen real estate for the photo preview while keeping professional controls accessible.

**Layout Structure:**
```
┌─────────────────────────────┐
│  [≡]              [HDR] [⚡] │  ← Top bar: settings, toggles
│                             │
│      VIEWFINDER             │
│      (edge-to-edge)         │
│                    [histogram]
│                             │
├─────────────────────────────┤
│  ISO │ SHUTTER │ FOCUS │ WB │  ← Dial selector row
│         ◀═══●═══▶           │  ← Active dial (swipe area)
│  [AUTO]    [ ◉ ]    [RAW]   │  ← Mode, shutter, format
└─────────────────────────────┘
```

**Key Characteristics:**

| Element | Behavior |
|---------|----------|
| **Viewfinder** | Edge-to-edge, no chrome until touched |
| **Controls** | Fade to 30% opacity after 3 seconds of inactivity |
| **Dial Strip** | Horizontal row; tap to select parameter, swipe to adjust |
| **Active Dial** | Expands slightly, shows value range, haptic on adjust |
| **Histogram** | Semi-transparent overlay, top-right, toggleable |
| **Shutter** | Large, centered, always fully visible |
| **Mode Toggle** | "AUTO" button bottom-left, one-tap escape |

## Design Rationale

1. **Viewfinder First** - Maximizes screen real estate for the photo preview; the image is always the star
2. **Halide Mental Model** - Users familiar with pro camera apps will feel immediately at home
3. **Progressive Disclosure** - Interface starts simple; complexity appears only when needed
4. **One-Handed Operation** - All controls positioned in thumb zone for portrait shooting
5. **Focus Through Subtraction** - Fading controls reduce visual noise; user focuses on composition

## Interaction States

| State | Behavior |
|-------|----------|
| **Idle** | Controls at 30% opacity, viewfinder dominates |
| **Active** | Touch in control zone → controls fade to 100% |
| **Adjusting** | Selected dial highlighted with accent color, value displayed large |
| **Capturing** | Brief flash animation, controls remain stable |
