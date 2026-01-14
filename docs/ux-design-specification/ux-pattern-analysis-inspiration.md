# UX Pattern Analysis & Inspiration

## Inspiring Products Analysis

**Native iPhone Camera**

The benchmark for speed and accessibility. Key UX strengths:
- **Instant Launch** - Camera ready in <1 second, even from lock screen
- **Zero Learning Curve** - Shutter button, viewfinder, done—anyone can use it
- **Thumb-First Design** - All critical controls reachable with one hand
- **Mode Switching** - Horizontal swipe between Photo/Video/Portrait
- **Tap-to-Focus** - Intuitive, immediate, with subtle exposure slider
- **Minimal Chrome** - Viewfinder dominates; controls fade when not needed

**Halide**

The gold standard for pro controls with elegant UI. Key UX strengths:
- **Gesture-Based Dials** - Swipe anywhere to adjust exposure—feels tactile
- **Focus Peaking** - Highlights sharp edges in vivid color overlay
- **Pro Data Display** - Histogram, ISO, shutter shown without clutter
- **RAW-First** - One-tap RAW toggle, clear format indicator
- **Depth Mode** - Manual focus with depth visualization
- **Dark UI** - Interface recedes, image is hero

## Transferable UX Patterns

| Pattern | Source | Application to Camera |
|---------|--------|----------------------|
| Swipe-anywhere dials | Halide | Core dial interaction for ISO/Shutter/Focus |
| Horizontal mode swipe | Native | Auto ↔ Pro mode switching gesture |
| Tap-to-focus with exposure slider | Native | Familiar focus interaction |
| Focus peaking overlay | Halide | Visual confirmation of sharpness |
| Minimal chrome / dark UI | Halide | Let the viewfinder be the hero |
| Instant launch priority | Native | Architecture must prioritize <1.5s launch |
| Thumb-zone design | Native | All controls in lower third of screen |

## Anti-Patterns to Avoid

- **Buried Settings** - Never hide critical controls in menus; pro controls must be surface-level
- **Modal Dialogs** - Never interrupt shooting flow with confirmations or alerts
- **Tutorial Overlays** - Avoid blocking the viewfinder with onboarding content
- **Cluttered HUD** - Don't show all data at once; use progressive disclosure
- **Slow Initialization** - Never sacrifice launch speed for feature loading

## Design Inspiration Strategy

**What to Adopt:**
- Halide's swipe-dial interaction as our core manual control paradigm
- Native Camera's tap-to-focus with exposure slider for familiar focus behavior
- Halide's dark, minimal UI that lets the viewfinder dominate
- Native Camera's thumb-zone placement for one-handed operation

**What to Adapt:**
- Native Camera's horizontal swipe for modes → adapt for Auto/Pro toggle
- Halide's focus peaking → ensure toggle is easily discoverable for new users

**What to Avoid:**
- Complex settings hierarchies that hide pro controls
- Any interaction that blocks or delays the capture moment
- Onboarding that requires dismissing overlays before shooting
