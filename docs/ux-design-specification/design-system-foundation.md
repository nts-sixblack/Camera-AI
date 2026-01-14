# Design System Foundation

## Design System Choice

**HIG Foundation + Pro Photography Aesthetic**

Camera will use Apple's Human Interface Guidelines as the foundation, layered with a custom dark-mode pro photography aesthetic. This hybrid approach provides native iOS familiarity while delivering the professional, tool-like feel that differentiates pro camera apps.

## Rationale for Selection

1. **Familiarity Breeds Trust** - Native iOS patterns (gestures, navigation, system controls) reduce learning curve and feel "right" to iPhone users
2. **Dark UI for Photography** - Professional photography apps use dark themes so the UI recedes and the image becomes the hero
3. **Custom Where It Matters** - Design investment focused on differentiating elements: swipe dials, focus peaking, histogram, exposure display
4. **SwiftUI Alignment** - HIG integrates naturally with SwiftUI, enabling faster development with native performance
5. **Accessibility Built-In** - Apple's accessibility features (Dynamic Type, VoiceOver) come free with HIG compliance

## Implementation Approach

| Layer | Approach |
|-------|----------|
| **Foundation** | Apple HIG patterns, SF Symbols, system haptics |
| **Theme** | Dark mode only, high contrast for outdoor visibility |
| **Typography** | SF Pro with customized weights for data display |
| **Controls** | Native iOS controls for settings; custom for shooting controls |
| **Color** | Minimal accent color; let the viewfinder image provide color |

## Customization Strategy

**Native Components (Use As-Is):**
- Navigation patterns
- Settings screens and toggles
- Permission dialogs
- Photo library integration

**Custom Components (Design from Scratch):**
- Swipe dial controls for ISO/Shutter/Focus/WB
- Histogram overlay
- Focus peaking visualization
- Exposure value display (ISO, shutter speed, aperture)
- Mode toggle (Auto/Pro)
- Shutter button with capture feedback

**Design Tokens:**
- Background: True black (#000000) for OLED efficiency
- Text: High-contrast white/gray for outdoor readability
- Accent: Single accent color for interactive elements
- Data: Monospace numerals for exposure values
