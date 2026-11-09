# MotionPlay — Hand Pinch Interaction Setup

This update adds MediaPipe Hand Landmarker live-stream detection and maps a thumb/index-finger pinch to fruit selection.

## Required model file

The MediaPipe package is already present in this project. Hand Landmarker additionally requires its model bundle:

**Download:** https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/latest/hand_landmarker.task

1. Download `hand_landmarker.task` from the link above.
2. Put the file inside the `MotionPlay` app source folder, beside `pose_landmarker_lite.task`.
3. In Xcode, make sure `hand_landmarker.task` is included in the MotionPlay app target. This project uses a synchronized `MotionPlay` folder group, so adding the file inside that folder should make it visible automatically. If Xcode asks, choose **Copy items if needed** and check the MotionPlay target.
4. Build and run on the physical iPad (not the simulator).

## Interaction

- The index fingertip is used as the on-screen pointer.
- Thumb tip (landmark 4) and index tip (landmark 8) distance is used for pinch detection.
- A pinch edge (open -> closed) selects the fruit under the pointer once.
- The pointer is mirrored horizontally to match the front-camera preview.
- Touch selection remains available as a fallback.

## Notes

- The app processes camera frames locally. No camera video is uploaded by this code.
- The current pointer-to-grid mapping assumes the camera image orientation matches the visible front-camera preview. If the pointer appears rotated or mirrored on the iPad, send a gameplay screenshot and we can adjust the coordinate mapping without changing the existing camera preview.
- I could not include the model binary in this archive. The official download link above is required before the hand tracker can initialize.
- Build and device behavior still need to be verified in Xcode on the iPad.
