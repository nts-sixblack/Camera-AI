---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
inputDocuments: []
documentCounts:
  briefCount: 0
  researchCount: 0
  brainstormingCount: 0
  projectDocsCount: 0
workflowType: 'prd'
lastStep: 1
---

# Product Requirements Document - Camera

**Author:** Sixblack
**Date:** 2026-01-07

## Executive Summary

The goal is to build a high-fidelity mobile camera application that rivals the native iPhone camera in feature set while distinguishing itself through professional-grade manual controls. This app targets photography enthusiasts and power users who appreciate the quality of the default camera but feel limited by its automatic decision-making. By exposing granular controls for focus, exposure, ISO, and shutter speed alongside replicated native features like Portrait and Night mode, we provide a "Pro" alternative that empowers creative intent without sacrificing the convenience of a smartphone.

### What Makes This Special

While the default iPhone camera prioritizes "point-and-shoot" simplicity with computational photography that often hides decisions from the user, this application serves as a **Pro-grade alternative**. The "aha" moment for users occurs when they can seamlessly toggle between an intelligent auto-mode (comparable to the default app) and a fully manual mode where they dictate the shot's parameters. It fills the gap for users who want the power of a DSLR interface combined with the computational prowess of the iPhone's hardware.

## Project Classification

**Technical Type:** Mobile App
**Domain:** General/Consumer
**Complexity:** High
**Project Context:** Greenfield - new project

## Success Criteria

### User Success

*   **Creative Control:** Users can manually adjust ISO, Shutter Speed, and Focus within 2 taps or seconds, enabling shots impossible in auto mode.
*   **Image Quality:** Users rate the image quality of RAW captures as superior or equal to the native camera in post-processing potential.
*   **Confidence:** Users feel confident that the "Pro" mode captured the data they need, evidenced by a low rate of immediate re-takes due to technical settings.

### Business Success

*   **Adoption:** Achieve [Target Number] active daily users within the first 6 months.
*   **Retention:** 40% of users who take a manual photo return to take another within 7 days.
*   **Reputation:** Maintain an App Store rating of 4.5+ stars, specifically praised for "control" and "quality."

### Technical Success

*   **Performance:** App launch to capture readiness time is under 1.5 seconds (comparable to native).
*   **Stability:** Crash-free sessions > 99.5%, especially during high-resolution RAW capture.
*   **Pipeline:** Zero dropped frames during 4K video recording or burst photo mode.

### Measurable Outcomes

*   **Metric:** Time to set manual exposure. **Target:** < 2 seconds.
*   **Metric:** Daily Active Users (DAU). **Target:** [Insert Growth Target].
*   **Metric:** App Store Rating. **Target:** > 4.5 Stars.

## Product Scope

### MVP - Minimum Viable Product

*   **Core Capture:** Photo and Video capture with native quality.
*   **Manual Controls:** Granular control over Focus, ISO, Shutter Speed, White Balance.
*   **Format Support:** RAW, ProRAW, HEIC, JPG support.
*   **Interface:** Clean, unobtrusive UI that puts controls at thumb-reach.

### Growth Features (Post-MVP)

*   **Advanced Tools:** Focus peaking, histograms, zebra stripes.
*   **Customization:** Presets for specific shooting scenarios (e.g., "Street", "Studio").
*   **Integration:** Social sharing shortcuts, basic in-app editing.

### Vision (Future)

*   **AI Assistance:** Smart assistants that suggest settings based on scene analysis without taking control away.
*   **Ecosystem:** Companion app for Apple Watch remote control, hardware accessory support (lenses, gimbals).

## User Journeys

### Journey 1: Elena - The Controlled Portrait
Elena is a street photographer who spots an interesting character in a cafe window. The lighting is mixed—bright sunlight outside, deep shadows inside. She knows the default camera will average the exposure and ruin the mood.

**The Action:**
1.  She launches Camera.
2.  She taps to focus on the subject's face.
3.  She swipes the "Exposure" dial down to -1.5 EV to crush the shadows and highlight the subject.
4.  She switches to "Portrait Mode" but manually adjusts the simulated aperture to f/2.8 for a natural falloff.
5.  She captures the shot.

**The Result:**
Reviewing the photo immediately, she sees the drama she intended. The highlights aren't blown out, and the focus is razor-sharp on the eyes. She feels like a photographer, not just a phone user.

### Journey 2: The "Hand-off" Panic
Elena is at a dinner party. She wants a group photo and hands her phone to the waiter. The waiter looks at the screen, confused by the histograms and manual sliders.

**The Action:**
1.  Elena realizes the waiter is confused.
2.  She taps a prominent "Auto" button (or "Simple Mode" toggle).
3.  The interface simplifies instantly—hiding dials, histograms, and peaking. It looks just like the default camera.
4.  The waiter smiles, recognizes the familiar shutter button, and takes the photo.

**The Result:**
The photo is safe, well-exposed, and in focus. Elena didn't miss the moment because of her tool's complexity.

### Journey Requirements Summary

These journeys reveal critical requirements:

*   **Manual Override:** Direct, low-latency access to Exposure, Focus, and Aperture simulation.
*   **Visual Feedback:** Histograms and focus peaking are needed to confirm "safe" shots before capture.
*   **Mode Switching:** A "Panic Button" or instant toggle to a simplified Auto interface is crucial for casual use or hand-offs.
*   **Speed:** Launch-to-capture time must be near-instant, even when loading Pro features.

## Mobile App Specific Requirements

### Project-Type Overview
This is a **Native iOS Application** built with Swift and SwiftUI to maximize performance and leverage low-level hardware APIs (AVFoundation, Metal). It prioritizes "Offline First" functionality and seamless integration with the system Photo Library.

### Technical Architecture Considerations
*   **Language:** Swift 6.x
*   **UI Framework:** SwiftUI (for HUD) + UIKit (where precise camera preview control is needed).
*   **Core Frameworks:** AVFoundation (Camera), Metal (Image Processing), PhotoKit (Library Management).
*   **Minimum iOS Version:** iOS 17.0 (to leverage latest camera features).

### Platform Requirements & Constraints
*   **Device Support:** iPhone only (optimized for iPhone 15 Pro and newer capabilities, gracefully degrading for older models).
*   **Orientation:** Portrait and Landscape support with UI rotation (but camera preview stays fixed relative to sensor).
*   **App Store Compliance:** Must adhere to Guideline 5.1.1 (Data Privacy) regarding camera and photo library usage.

### Device Permissions & Capabilities
*   **Camera:** Essential. Must handle "denied" state gracefully with instructions to enable in Settings.
*   **Microphone:** Optional (only triggered if video mode is accessed).
*   **Photo Library:** Read/Write access required to save captures to the user's main Camera Roll.
*   **Location:** Optional. User can opt-in for geotagging.
*   **Offline Mode:** App functions 100% without internet. No account creation required.

### Implementation Considerations
*   **Cold Start Latency:** Architecture must prioritize initializing the camera session immediately, loading UI secondary.
*   **Thermal Management:** Heavy RAW/ProRAW processing can heat up the device. Implement thermal state monitoring to throttle non-essential tasks.
*   **Memory Management:** High-res RAW buffers are large. Aggressive memory pooling required to prevent OOM crashes during burst mode.

## Project Scoping & Phased Development

### MVP Strategy & Philosophy
**MVP Approach:** **Experience MVP**
The goal is to deliver a premium "shooting feel" from day one. We prioritize the responsiveness of the dials, the clarity of the viewfinder, and the reliability of the capture over a massive feature list. If the manual controls feel clunky, we fail.

**Resource Requirements:** Small, high-skill team (1 iOS Engineer, 1 Designer) focusing on UI polish and Metal performance.

### MVP Feature Set (Phase 1)
**Core User Journeys Supported:**
*   Elena's Controlled Portrait (Manual Focus/Exposure)
*   The "Panic" Moment (Auto Toggle)

**Must-Have Capabilities:**
*   **Manual Controls:** ISO, Shutter Speed, Focus, White Balance (Kelvin/Presets).
*   **Visual Aids:** Live Histogram, Focus Peaking.
*   **Capture:** RAW, HEIC, JPG support.
*   **Library:** Save directly to Camera Roll.

### Post-MVP Features

**Phase 2 (Growth):**
*   **Advanced Aids:** Zebra Stripes, False Color.
*   **Video Pro:** Manual controls for video (Frame rate, bitrate).
*   **Customization:** Custom Presets.

**Phase 3 (Expansion):**
*   **Editor:** Non-destructive RAW editing in-app.
*   **Hardware:** Support for anamorphic lenses (de-squeeze).

### Risk Mitigation Strategy
**Technical Risks:** *Performance.*
*   **Mitigation:** Prototype the viewfinder pipeline in Metal immediately to ensure <16ms latency for UI updates.

**Market Risks:** *Complexity.*
*   **Mitigation:** Beta test the "Auto" toggle heavily to ensure users don't get stuck in bad settings.

## Functional Requirements

### Camera Capture Control
*   **FR1:** User can manually adjust ISO value with immediate preview feedback.
*   **FR2:** User can manually adjust Shutter Speed with immediate preview feedback.
*   **FR3:** User can manually adjust Focus distance with visual confirmation.
*   **FR4:** User can select White Balance from presets (Sunny, Cloudy, etc.) or set a custom Kelvin value.
*   **FR5:** User can toggle "Auto" mode to instantly reset all manual parameters to automatic.
*   **FR6:** User can switch between available hardware lenses (Ultra Wide, Wide, Telephoto).

### Viewfinder & Visual Aids
*   **FR7:** User can view a real-time RGB histogram overlaid on the viewfinder.
*   **FR8:** User can toggle "Focus Peaking" to highlight in-focus edges with a contrasting color.
*   **FR9:** User can tap-to-focus on a specific point in the viewfinder.
*   **FR10:** User can lock Exposure and Focus (AE/AF Lock) independently.
*   **FR11:** User can view current exposure values (ISO, Shutter, Aperture) at all times in Pro mode.

### Asset Management
*   **FR12:** User can capture images in RAW (DNG) format.
*   **FR13:** User can capture images in HEIC or JPG format.
*   **FR14:** System must save captured assets directly to the device's main Photo Library.
*   **FR15:** User can toggle geotagging (Location Metadata) on or off.

### App State & Settings
*   **FR16:** System must persist the last used shooting mode (Auto vs Manual) between sessions.
*   **FR17:** System must request necessary permissions (Camera, Photo Library) with context explanations.
*   **FR18:** System must gracefully handle denied permissions by directing user to Settings.

## Non-Functional Requirements

### Performance (CRITICAL)
*   **Capture Rate:** System must support continuous RAW capture at minimum 10 FPS for at least 3 seconds (buffer depth) without dropping frames.
*   **Launch Latency:** App must be ready to capture (live preview active, buttons responsive) within 1.5 seconds of cold launch on iPhone 15 Pro.
*   **Viewfinder Latency:** Glass-to-glass latency must remain under 50ms to prevent "swimming" effect during panning.
*   **UI Responsiveness:** All manual dial interactions must update the preview at 60 FPS (16ms frame budget).

### Reliability
*   **Thermal Throttling:** App must monitor  and gracefully degrade (disable high-fps viewfinder, pause background processing) BEFORE the system terminates the app.
*   **Crash Rate:** Must maintain > 99.5% crash-free sessions.
*   **Memory Safety:** App must strictly adhere to iOS memory limits (specifically during high-res burst capture) to avoid OOM kills.

### Security & Privacy
*   **Data Minimization:** App must strictly use Camera and Photo Library permissions only for capture and saving. No data is collected or transmitted.
*   **Photo Library:** App must correctly handle "Limited Access" permission state if user selects it.
