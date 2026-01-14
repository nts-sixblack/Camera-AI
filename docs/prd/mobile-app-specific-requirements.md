# Mobile App Specific Requirements

## Project-Type Overview
This is a **Native iOS Application** built with Swift and SwiftUI to maximize performance and leverage low-level hardware APIs (AVFoundation, Metal). It prioritizes "Offline First" functionality and seamless integration with the system Photo Library.

## Technical Architecture Considerations
*   **Language:** Swift 6.x
*   **UI Framework:** SwiftUI (for HUD) + UIKit (where precise camera preview control is needed).
*   **Core Frameworks:** AVFoundation (Camera), Metal (Image Processing), PhotoKit (Library Management).
*   **Minimum iOS Version:** iOS 17.0 (to leverage latest camera features).

## Platform Requirements & Constraints
*   **Device Support:** iPhone only (optimized for iPhone 15 Pro and newer capabilities, gracefully degrading for older models).
*   **Orientation:** Portrait and Landscape support with UI rotation (but camera preview stays fixed relative to sensor).
*   **App Store Compliance:** Must adhere to Guideline 5.1.1 (Data Privacy) regarding camera and photo library usage.

## Device Permissions & Capabilities
*   **Camera:** Essential. Must handle "denied" state gracefully with instructions to enable in Settings.
*   **Microphone:** Optional (only triggered if video mode is accessed).
*   **Photo Library:** Read/Write access required to save captures to the user's main Camera Roll.
*   **Location:** Optional. User can opt-in for geotagging.
*   **Offline Mode:** App functions 100% without internet. No account creation required.

## Implementation Considerations
*   **Cold Start Latency:** Architecture must prioritize initializing the camera session immediately, loading UI secondary.
*   **Thermal Management:** Heavy RAW/ProRAW processing can heat up the device. Implement thermal state monitoring to throttle non-essential tasks.
*   **Memory Management:** High-res RAW buffers are large. Aggressive memory pooling required to prevent OOM crashes during burst mode.
