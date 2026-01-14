# User Journeys

## Journey 1: Elena - The Controlled Portrait
Elena is a street photographer who spots an interesting character in a cafe window. The lighting is mixed—bright sunlight outside, deep shadows inside. She knows the default camera will average the exposure and ruin the mood.

**The Action:**
1.  She launches Camera.
2.  She taps to focus on the subject's face.
3.  She swipes the "Exposure" dial down to -1.5 EV to crush the shadows and highlight the subject.
4.  She switches to "Portrait Mode" but manually adjusts the simulated aperture to f/2.8 for a natural falloff.
5.  She captures the shot.

**The Result:**
Reviewing the photo immediately, she sees the drama she intended. The highlights aren't blown out, and the focus is razor-sharp on the eyes. She feels like a photographer, not just a phone user.

## Journey 2: The "Hand-off" Panic
Elena is at a dinner party. She wants a group photo and hands her phone to the waiter. The waiter looks at the screen, confused by the histograms and manual sliders.

**The Action:**
1.  Elena realizes the waiter is confused.
2.  She taps a prominent "Auto" button (or "Simple Mode" toggle).
3.  The interface simplifies instantly—hiding dials, histograms, and peaking. It looks just like the default camera.
4.  The waiter smiles, recognizes the familiar shutter button, and takes the photo.

**The Result:**
The photo is safe, well-exposed, and in focus. Elena didn't miss the moment because of her tool's complexity.

## Journey Requirements Summary

These journeys reveal critical requirements:

*   **Manual Override:** Direct, low-latency access to Exposure, Focus, and Aperture simulation.
*   **Visual Feedback:** Histograms and focus peaking are needed to confirm "safe" shots before capture.
*   **Mode Switching:** A "Panic Button" or instant toggle to a simplified Auto interface is crucial for casual use or hand-offs.
*   **Speed:** Launch-to-capture time must be near-instant, even when loading Pro features.
