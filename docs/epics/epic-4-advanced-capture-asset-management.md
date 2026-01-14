# Epic 4: Advanced Capture & Asset Management

Users can capture in RAW/ProRAW formats and control geotagging for professional-grade asset management.

## Story 4.1: RAW (DNG) Capture Format

As a **professional photographer**,
I want **to capture images in RAW (DNG) format**,
So that **I have maximum flexibility for post-processing with full sensor data preserved**.

**Acceptance Criteria:**

**Given** the device supports RAW capture (iPhone 12+)
**When** the user enables the RAW format toggle
**Then** the capture mode switches to RAW (DNG)
**And** a "RAW" indicator is prominently displayed on screen

**Given** RAW mode is enabled
**When** the user taps the shutter button
**Then** a RAW image is captured with full sensor data
**And** the image is saved as a DNG file to the Photo Library
**And** the file contains uncompressed or losslessly compressed sensor data

**Given** RAW capture completes
**When** the file is saved
**Then** the DNG file includes all capture metadata (ISO, shutter speed, aperture, WB)
**And** the file is compatible with standard RAW editors (Lightroom, Capture One, Photos)

**Given** the device does not support RAW capture (older models)
**When** the app loads
**Then** the RAW toggle is hidden or disabled with explanation

**RAW File Specifications:**
- Format: DNG (Digital Negative) per Adobe DNG specification
- Bit Depth: 12-bit or 14-bit (device-dependent)
- Compression: Lossless or uncompressed
- Typical File Size: 20-50MB per image

**Technical Implementation:** Use `AVCapturePhotoOutput` with `AVCapturePhotoSettings`. Check `availableRawPhotoPixelFormatTypes` for RAW support. Set `rawPhotoPixelFormatType` to a supported Bayer format. In delegate callback `photoOutput(_:didFinishProcessingPhoto:)`, access `photo.fileDataRepresentation()` for DNG data. Save via `PHAssetCreationRequest.addResource(with: .photo, data:, options:)`.

---

## Story 4.2: Apple ProRAW Capture (Enhanced RAW)

As a **professional photographer with iPhone 12 Pro or later**,
I want **to capture in Apple ProRAW format**,
So that **I get computational photography benefits (Deep Fusion, Smart HDR) combined with RAW flexibility**.

**Acceptance Criteria:**

**Given** the device supports ProRAW (iPhone 12 Pro+ with iOS 14.3+)
**When** the user enables the ProRAW format toggle
**Then** the capture mode switches to Apple ProRAW
**And** a "ProRAW" indicator is prominently displayed on screen

**Given** ProRAW mode is enabled
**When** the user taps the shutter button
**Then** a ProRAW image is captured with computational enhancements baked in
**And** the image is saved as a DNG file with extended dynamic range
**And** the file size is approximately 25-40MB

**Given** ProRAW capture completes
**When** reviewed in a compatible editor
**Then** the image shows enhanced shadow/highlight detail from computational processing
**And** the file remains fully editable as a RAW file

**Given** the device does not support ProRAW
**When** the app loads
**Then** the ProRAW option is hidden, and standard RAW (if supported) is offered instead

**Technical Implementation:** Check `isAppleProRAWSupported` on `AVCapturePhotoOutput`. Enable via `isAppleProRAWEnabled = true` before capture. Use `AVCapturePhotoSettings` with `rawPhotoPixelFormatType` from `availableRawPhotoPixelFormatTypes`.

---

## Story 4.3: Format Selection Toggle (RAW/ProRAW/HEIC)

As a **photographer**,
I want **a clear toggle to switch between capture formats (HEIC, RAW, ProRAW)**,
So that **I can choose the appropriate format for my current shooting needs**.

**Acceptance Criteria:**

**Given** the format toggle is displayed
**When** the user views available options
**Then** only device-supported formats are shown:
  - All devices: HEIC/JPG
  - iPhone 12+: RAW (DNG)
  - iPhone 12 Pro+: ProRAW

**Given** the user selects a format
**When** the selection is made
**Then** the format applies immediately to subsequent captures
**And** the selected format is visually indicated
**And** haptic feedback confirms the selection

**Given** the user has selected a format
**When** the app is closed and reopened
**Then** the format preference persists

**Technical Implementation:** Store format preference in `UserDefaults`. Query device capabilities on launch via `AVCapturePhotoOutput.availableRawPhotoPixelFormatTypes` and `isAppleProRAWSupported`.

---

## Story 4.4: Location Permission Request for Geotagging

As a **user**,
I want **the app to request location access with a clear explanation when I enable geotagging**,
So that **I understand why location data is needed and can make an informed choice**.

**Acceptance Criteria:**

**Given** geotagging is disabled (default)
**When** the user enables the geotag toggle for the first time
**Then** a system location permission dialog is presented
**And** the usage description explains photos will include GPS coordinates

**Given** the user grants location permission ("While Using App")
**When** the permission is confirmed
**Then** geotagging becomes active
**And** subsequent photos include GPS metadata

**Given** the user grants "Precise" location
**When** a photo is captured with geotagging enabled
**Then** the photo includes accurate GPS coordinates

**Given** the user grants only "Approximate" location
**When** a photo is captured with geotagging enabled
**Then** the photo includes approximate GPS coordinates

**Given** the user denies location permission
**When** the denial is confirmed
**Then** the geotag toggle returns to "off" state
**And** an explanation with "Open Settings" button is shown

**Technical Implementation:** Use `CLLocationManager.requestWhenInUseAuthorization()`. Check `CLLocationManager.authorizationStatus()`. Request with Info.plist `NSLocationWhenInUseUsageDescription`.

---

## Story 4.5: Geotagging Toggle and GPS Metadata Injection

As a **photographer**,
I want **to toggle geotagging on or off to control whether my photos include location data**,
So that **I can add location context when desired or protect my privacy when needed**.

**Acceptance Criteria:**

**Given** location permission is granted
**When** the user enables the geotag toggle
**Then** geotagging becomes active
**And** a location indicator (GPS icon) appears on screen

**Given** geotagging is enabled
**When** a photo is captured
**Then** the saved image includes GPS coordinates in Exif metadata
**And** the coordinates reflect the device's location at capture time

**Given** geotagging is enabled
**When** the device cannot acquire a location fix (indoors, no signal)
**Then** the photo is saved without GPS metadata

**Given** the user disables the geotag toggle
**When** subsequent photos are captured
**Then** no GPS metadata is included in the photos (FR15)

**Given** the user changes the geotag setting
**When** the app is closed and reopened
**Then** the geotag preference persists

**Exif GPS Metadata Fields:**
- GPSLatitude, GPSLatitudeRef
- GPSLongitude, GPSLongitudeRef
- GPSAltitude, GPSAltitudeRef
- GPSDateStamp, GPSTimeStamp

**Technical Implementation:** Use `CLLocationManager` to get current location. Inject GPS metadata into `AVCapturePhotoSettings` via the `metadata` property or embed in DNG Exif during save. For PHAsset saving, use `PHAssetCreationRequest` with `creationRequest.location = CLLocation(...)`.

---

## Story 4.6: Background Save with Progress Indication

As a **photographer capturing RAW images**,
I want **the save operation to happen in the background without blocking the viewfinder**,
So that **I can continue shooting while large files are being written**.

**Acceptance Criteria:**

**Given** a photo is captured (especially RAW/ProRAW)
**When** the capture completes
**Then** the viewfinder returns to ready state immediately
**And** the save operation continues in the background
**And** the user can capture additional photos without waiting

**Given** a background save is in progress
**When** the user views the UI
**Then** a subtle save indicator is visible (e.g., small progress ring or "Saving..." badge)

**Given** multiple photos are captured rapidly
**When** saves are queued
**Then** saves process sequentially in a background queue
**And** a queue indicator shows pending saves (e.g., "Saving 3...")

**Given** all saves complete
**When** the queue is empty
**Then** the save indicator disappears

**Given** a save fails (e.g., storage full)
**When** the failure occurs
**Then** a non-blocking error notification appears
**And** retry or discard options are available

**Technical Implementation:** Use `DispatchQueue` with `.userInitiated` QoS for save operations. Implement serial queue for Photo Library writes. Use `PHPhotoLibrary.shared().performChanges` with completion handler. Track save queue state in `@Published` property.

---

## Story 4.7: Memory Management for RAW Buffers

As a **photographer using burst or continuous capture**,
I want **the app to manage memory efficiently when handling large RAW buffers**,
So that **the app remains stable and doesn't crash due to memory pressure**.

**Acceptance Criteria:**

**Given** RAW capture mode is active
**When** the user captures photos
**Then** the app manages RAW buffers efficiently
**And** buffers are released promptly after saving
**And** memory usage stays within iOS limits (NFR7)

**Given** the user captures rapidly (burst-like behavior)
**When** multiple RAW captures are in progress
**Then** the app queues captures appropriately
**And** maintains minimum 10 FPS for 3 seconds (30 frames) without dropping (NFR1)

**Given** the system signals memory pressure
**When** the app receives memory warning
**Then** the app aggressively releases cached buffers
**And** limits pending capture queue size
**And** prioritizes completing in-progress saves

**Given** extreme memory pressure occurs
**When** the app must respond immediately
**Then** the app gracefully cancels pending captures rather than crashing

**Technical Implementation:** Use autoreleasepool blocks around capture callbacks. Monitor memory via `os_proc_available_memory()`. Set capture queue depth limits. Subscribe to `UIApplication.didReceiveMemoryWarningNotification`. For burst, check `supportedMaxPhotoDimensions` for buffer sizing.

---

## Story 4.8: Storage Space Awareness

As a **photographer**,
I want **the app to warn me when storage space is low before I capture large RAW files**,
So that **I don't lose shots due to failed saves**.

**Acceptance Criteria:**

**Given** device storage is low (< 500MB free)
**When** the user has RAW/ProRAW mode enabled
**Then** a warning indicator appears ("Low Storage")
**And** estimated remaining RAW shots is displayed

**Given** device storage is critically low (< 100MB free)
**When** the user attempts to capture
**Then** a more prominent warning is shown

**Given** a save fails due to insufficient storage
**When** the error occurs
**Then** the user is clearly notified ("Storage Full - Photo not saved")
**And** suggestion to free space or switch to HEIC is provided

**Given** storage was low but space is freed
**When** the app checks storage again
**Then** the warning disappears

**Technical Implementation:** Query available storage via `FileManager.default.attributesOfFileSystem(forPath:)` with key `FileAttributeKey.systemFreeSize`. Calculate estimated remaining shots based on ~30MB average RAW size. Check storage on app foreground and before capture.

---
