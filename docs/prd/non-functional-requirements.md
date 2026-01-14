# Non-Functional Requirements

## Performance (CRITICAL)
*   **Capture Rate:** System must support continuous RAW capture at minimum 10 FPS for at least 3 seconds (buffer depth) without dropping frames.
*   **Launch Latency:** App must be ready to capture (live preview active, buttons responsive) within 1.5 seconds of cold launch on iPhone 15 Pro.
*   **Viewfinder Latency:** Glass-to-glass latency must remain under 50ms to prevent "swimming" effect during panning.
*   **UI Responsiveness:** All manual dial interactions must update the preview at 60 FPS (16ms frame budget).

## Reliability
*   **Thermal Throttling:** App must monitor  and gracefully degrade (disable high-fps viewfinder, pause background processing) BEFORE the system terminates the app.
*   **Crash Rate:** Must maintain > 99.5% crash-free sessions.
*   **Memory Safety:** App must strictly adhere to iOS memory limits (specifically during high-res burst capture) to avoid OOM kills.

## Security & Privacy
*   **Data Minimization:** App must strictly use Camera and Photo Library permissions only for capture and saving. No data is collected or transmitted.
*   **Photo Library:** App must correctly handle "Limited Access" permission state if user selects it.
