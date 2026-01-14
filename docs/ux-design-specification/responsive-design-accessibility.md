# Responsive Design & Accessibility

## Responsive Strategy

- **Platform Scope:** iPhone-first UI, scaled up for iPad (no separate tablet layout).
- **Orientation:** Portrait-only UI; viewfinder remains sensor-aligned.
- **Layout Behavior:** Core controls remain in the thumb zone; spacing scales up on larger devices.
- **iPad Treatment:** Same control hierarchy and interaction model as iPhone, with increased padding and larger tap targets.

## Breakpoint Strategy

- **Device-Class Breakpoints:** Use device classes rather than generic web breakpoints.
  - iPhone mini / SE class
  - iPhone standard / Pro
  - iPhone Max / Plus
  - iPad (scaled iPhone UI)
- **Mobile-First:** All layouts originate from iPhone; iPad inherits scaled layout without additional panels.

## Accessibility Strategy

- **Target Level:** WCAG AA.
- **Contrast:** Maintain 4.5:1 for text and 3:1 for large labels.
- **Touch Targets:** Minimum 44x44pt across all controls.
- **Screen Readers:** Full VoiceOver labeling for all controls, including camera state and exposure values.
- **Focus & Feedback:** Clear focus states, haptic feedback paired with visual cues.
- **Reduced Motion:** Respect system Reduce Motion for animations.

## Testing Strategy

- **Device Testing:** iPhone SE/mini, standard, Max/Plus, and iPad.
- **Accessibility Testing:** VoiceOver, Larger Text, High Contrast, and Reduce Motion.
- **Visual Checks:** Contrast checks for all UI overlays on dark backgrounds.
- **Interaction Testing:** One-handed reachability and portrait-only constraints.

## Implementation Guidelines

- **Responsive Development:**
  - Use scalable layout constants (spacing/padding) by device class.
  - Keep controls anchored to bottom thumb zone in portrait.
- **Accessibility Development:**
  - Provide VoiceOver labels and hints for all controls and states.
  - Use SF Symbols with accessible labels.
  - Avoid relying on color alone for warnings.

