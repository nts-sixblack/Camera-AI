# Functional Requirements

## Camera Capture Control
*   **FR1:** User can manually adjust ISO value with immediate preview feedback.
*   **FR2:** User can manually adjust Shutter Speed with immediate preview feedback.
*   **FR3:** User can manually adjust Focus distance with visual confirmation.
*   **FR4:** User can select White Balance from presets (Sunny, Cloudy, etc.) or set a custom Kelvin value.
*   **FR5:** User can toggle "Auto" mode to instantly reset all manual parameters to automatic.
*   **FR6:** User can switch between available hardware lenses (Ultra Wide, Wide, Telephoto).

## Viewfinder & Visual Aids
*   **FR7:** User can view a real-time RGB histogram overlaid on the viewfinder.
*   **FR8:** User can toggle "Focus Peaking" to highlight in-focus edges with a contrasting color.
*   **FR9:** User can tap-to-focus on a specific point in the viewfinder.
*   **FR10:** User can lock Exposure and Focus (AE/AF Lock) independently.
*   **FR11:** User can view current exposure values (ISO, Shutter, Aperture) at all times in Pro mode.

## Asset Management
*   **FR12:** User can capture images in RAW (DNG) format.
*   **FR13:** User can capture images in HEIC or JPG format.
*   **FR14:** System must save captured assets directly to the device's main Photo Library.
*   **FR15:** User can toggle geotagging (Location Metadata) on or off.

## App State & Settings
*   **FR16:** System must persist the last used shooting mode (Auto vs Manual) between sessions.
*   **FR17:** System must request necessary permissions (Camera, Photo Library) with context explanations.
*   **FR18:** System must gracefully handle denied permissions by directing user to Settings.
