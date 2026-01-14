# User Journey Flows

## Journey 1: Manual Pro Capture

**Scenario:** User wants to capture a photo with intentional manual settings (Elena's Controlled Portrait)

```mermaid
flowchart TD
    A[Launch App] --> B[Viewfinder Active]
    B --> C{Mode?}
    C -->|Auto| D[Tap PRO toggle]
    C -->|Pro| E[Controls visible]
    D --> E
    E --> F[Tap to focus on subject]
    F --> G[Focus peaking confirms sharp]
    G --> H[Tap ISO dial]
    H --> I[Swipe to adjust ISO]
    I --> J[Haptic + preview updates]
    J --> K[Tap SHUTTER dial]
    K --> L[Swipe to adjust speed]
    L --> M[Check histogram]
    M --> N{Exposure OK?}
    N -->|No| H
    N -->|Yes| O[Tap shutter button]
    O --> P[Flash + haptic confirms]
    P --> Q[Image saved to library]
    Q --> R{Another shot?}
    R -->|Yes| F
    R -->|No| S[Exit or review]
```

**Key Interactions:**

| Step | Action | Feedback |
|------|--------|----------|
| Focus | Tap viewfinder | Focus peaking highlight, focus box |
| Select dial | Tap dial label | Dial expands, accent color |
| Adjust value | Swipe up/down | Haptic tick, preview updates, value changes |
| Capture | Tap shutter | Flash animation, haptic, save confirmation |

## Journey 2: Auto Mode Escape

**Scenario:** User needs to quickly simplify the interface for someone else (The "Hand-off" Panic)

```mermaid
flowchart TD
    A[In Pro Mode] --> B[Complex UI visible]
    B --> C[Hand phone to friend]
    C --> D[Friend looks confused]
    D --> E[Tap AUTO button]
    E --> F[UI instantly simplifies]
    F --> G[Only viewfinder + shutter visible]
    G --> H[Friend taps shutter]
    H --> I[Photo captured]
    I --> J[Success!]
```

**Key Interactions:**

| Step | Action | Feedback |
|------|--------|----------|
| Escape | Tap AUTO | Instant transition (<500ms), dials hide, clean UI |
| Capture | Tap shutter | Standard capture flow |

## Journey 3: First Launch & Permission Flow

**Scenario:** New user opens app for the first time

```mermaid
flowchart TD
    A[First Launch] --> B[Camera permission prompt]
    B --> C{Permission granted?}
    C -->|Yes| D[Viewfinder activates]
    C -->|No| E[Explain camera need]
    E --> F[Link to Settings]
    D --> G[Auto mode by default]
    G --> H[User sees familiar interface]
    H --> I[PRO toggle visible but subtle]
    I --> J{User explores?}
    J -->|Tap PRO| K[Pro controls appear]
    J -->|Ignore| L[Use as simple camera]
    K --> M[Discovery complete]
```

## Journey Patterns

**Navigation Patterns:**
- **Mode Toggle:** Single tap switches between Auto and Pro instantly
- **Dial Selection:** Tap to select, swipe to adjust (no mode required)
- **Focus Control:** Tap anywhere on viewfinder to set focus point

**Feedback Patterns:**
- **Haptic Confirmation:** Every value change, every capture
- **Visual Confirmation:** Focus peaking, histogram shift, flash on capture
- **State Indication:** Active dial highlighted with accent color

**Error Recovery Patterns:**
- **Permission Denied:** Clear explanation + deep link to Settings
- **Overexposure Warning:** Histogram shows clipping in yellow/red
- **One-Tap Reset:** AUTO button resets all manual settings

## Flow Optimization Principles

1. **Minimum Taps to Capture:** Pro mode capture possible in 3 taps (focus, adjust, shutter)
2. **No Dead Ends:** Every state has a clear next action or escape route
3. **Preserve Intent:** Manual settings persist until explicitly changed
4. **Graceful Degradation:** Auto mode always available as fallback
5. **Zero Onboarding:** Interface discoverable without tutorials
