# UX Consistency Patterns

## Button Hierarchy

**Primary Actions (Always prominent):**
- **Shutter** is the primary action; centered, largest hit target, always visible.
- **AUTO/PRO toggle** is the primary escape action; always reachable in thumb zone.

**Secondary Actions (Contextual, but visible):**
- **Lens switch, RAW toggle, HDR/Flash** appear in top bar or adjacent cluster.
- Secondary buttons are smaller, lower contrast, and never compete with shutter.

**Tertiary Actions (Hidden or low-priority):**
- Settings and advanced tools live behind a single icon (e.g., gear or menu) and should not block capture flow.

**When to Use:**
- Primary: actions that enable or trigger capture.
- Secondary: actions that adjust the shot or mode.
- Tertiary: infrequent configuration.

**Visual Design:**
- Primary buttons: high-contrast fill, accent color or white ring on black.
- Secondary buttons: outlined or ghost style, lower contrast.
- Tertiary buttons: icon-only, muted.

**Behavior:**
- Primary actions never move or disappear.
- Secondary actions can fade to 30% opacity in idle state but remain tappable.

**Accessibility:**
- Minimum 44x44pt touch targets.
- High-contrast state for outdoor visibility.
- VoiceOver labels for all controls (“Shutter button”, “Switch to Pro”).

**Mobile Considerations:**
- Thumb-zone placement for primary/secondary actions.
- Avoid top-right-only critical actions for one-handed use.

**Variants:**
- Active state: accent highlight and haptic tick.
- Disabled state: 40% opacity with clear label if disabled.

## Feedback Patterns

**Capture Feedback (Success):**
- Subtle flash animation on capture.
- Haptic confirmation on shutter press.
- Optional tone (user preference).

**Adjustment Feedback (Info):**
- Dial changes show immediate preview response.
- Haptic tick per value step.
- Histogram and focus peaking update live.

**Warning Feedback (Caution):**
- Exposure clipping indicated in yellow/red in histogram.
- Over/under exposure warning icon appears near exposure values.

**Error Feedback (Critical):**
- Permission denied: inline message with “Open Settings” button.
- Capture failure: non-blocking toast with retry suggestion.

**When to Use:**
- Success: completed capture or setting applied.
- Info: continuous adjustments.
- Warning: exposure risk or thermal throttling.
- Error: permissions or capture failure.

**Visual Design:**
- Success: green indicator or subtle check.
- Warning: yellow/orange (aligned with system palette).
- Error: red with clear iconography.

**Behavior:**
- Feedback must never block capture flow.
- Errors should not dismiss the viewfinder.

**Accessibility:**
- Haptics paired with visual feedback.
- Color-coded warnings also include icons/text.

**Mobile Considerations:**
- Toasts appear above bottom controls to avoid occluding shutter.
- Use short, glanceable feedback.

## Additional Patterns

**None defined in this step.**
