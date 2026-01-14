# Project Scoping & Phased Development

## MVP Strategy & Philosophy
**MVP Approach:** **Experience MVP**
The goal is to deliver a premium "shooting feel" from day one. We prioritize the responsiveness of the dials, the clarity of the viewfinder, and the reliability of the capture over a massive feature list. If the manual controls feel clunky, we fail.

**Resource Requirements:** Small, high-skill team (1 iOS Engineer, 1 Designer) focusing on UI polish and Metal performance.

## MVP Feature Set (Phase 1)
**Core User Journeys Supported:**
*   Elena's Controlled Portrait (Manual Focus/Exposure)
*   The "Panic" Moment (Auto Toggle)

**Must-Have Capabilities:**
*   **Manual Controls:** ISO, Shutter Speed, Focus, White Balance (Kelvin/Presets).
*   **Visual Aids:** Live Histogram, Focus Peaking.
*   **Capture:** RAW, HEIC, JPG support.
*   **Library:** Save directly to Camera Roll.

## Post-MVP Features

**Phase 2 (Growth):**
*   **Advanced Aids:** Zebra Stripes, False Color.
*   **Video Pro:** Manual controls for video (Frame rate, bitrate).
*   **Customization:** Custom Presets.

**Phase 3 (Expansion):**
*   **Editor:** Non-destructive RAW editing in-app.
*   **Hardware:** Support for anamorphic lenses (de-squeeze).

## Risk Mitigation Strategy
**Technical Risks:** *Performance.*
*   **Mitigation:** Prototype the viewfinder pipeline in Metal immediately to ensure <16ms latency for UI updates.

**Market Risks:** *Complexity.*
*   **Mitigation:** Beta test the "Auto" toggle heavily to ensure users don't get stuck in bad settings.
