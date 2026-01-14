# Visual Design Foundation

## Color System

| Role | Color | Hex | Usage |
|------|-------|-----|-------|
| **Background** | True Black | `#000000` | Viewfinder, main UI (OLED-efficient) |
| **Surface** | Dark Gray | `#1C1C1E` | Cards, controls, overlays |
| **Text Primary** | White | `#FFFFFF` | Labels, values, critical info |
| **Text Secondary** | Medium Gray | `#8E8E93` | Hints, inactive states |
| **Accent** | Signal Orange | `#FF9500` | Interactive elements, focus indicators |
| **Success** | Green | `#30D158` | Confirmation, in-focus indicator |
| **Warning** | Yellow | `#FFD60A` | Exposure warnings, histogram clipping |
| **Error** | Red | `#FF453A` | Errors, overexposure alerts |

**Color Rationale:**
- True black maximizes OLED battery life and makes viewfinder image "pop"
- Single accent color (orange) signals interactivity without competing with photo content
- Semantic colors (success/warning/error) provide instant feedback on exposure safety

## Typography System

| Element | Font | Weight | Size |
|---------|------|--------|------|
| **Exposure Values** | SF Mono | Medium | 17pt |
| **Control Labels** | SF Pro | Semibold | 13pt |
| **Mode Indicator** | SF Pro | Bold | 15pt |
| **Settings Headers** | SF Pro | Bold | 17pt |
| **Body Text** | SF Pro | Regular | 15pt |

**Typography Rationale:**
- Monospace for exposure data ensures alignment and precision feel
- SF Pro for all other text maintains iOS native feel
- Clear hierarchy distinguishes data from labels

## Spacing & Layout Foundation

| Element | Value |
|---------|-------|
| **Base Unit** | 8pt |
| **Control Padding** | 16pt (2x base) |
| **Thumb Zone** | Bottom 180pt of screen |
| **Viewfinder Margin** | 0pt (edge-to-edge) |
| **Control Spacing** | 24pt between dial groups |
| **Safe Area Respect** | Yes (notch, home indicator) |

**Layout Principles:**
1. **Viewfinder First** - Image preview gets maximum screen real estate
2. **Thumb Zone Controls** - All shooting controls in lower third
3. **Progressive Reveal** - Pro controls appear on mode switch, not cluttering Auto mode
4. **Edge-to-Edge** - No margins on viewfinder; controls float on top

## Accessibility Considerations

- All text meets WCAG AA contrast ratio (4.5:1 minimum)
- Interactive elements meet 44x44pt minimum touch target
- VoiceOver labels for all controls
- Support for Bold Text and Larger Accessibility Sizes in settings screens
- High contrast mode: boost text to pure white, increase control borders
