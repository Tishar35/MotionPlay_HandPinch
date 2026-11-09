import Foundation
import AVFoundation
import MediaPipeTasksVision
import CoreGraphics

final class HandLandmarkerManager: NSObject, HandLandmarkerLiveStreamDelegate {

    private var handLandmarker: HandLandmarker?
    var onHandUpdate: ((CGPoint?, Bool) -> Void)?

    override init() {
        super.init()
        setupHandLandmarker()
    }

    private func setupHandLandmarker() {
        guard let modelPath = Bundle.main.path(
            forResource: "hand_landmarker",
            ofType: "task"
        ) else {
            print("ERROR: hand_landmarker.task not found in app bundle.")
            return
        }

        let options = HandLandmarkerOptions()
        options.baseOptions.modelAssetPath = modelPath
        options.runningMode = .liveStream
        options.numHands = 1
        options.minHandDetectionConfidence = 0.5
        options.minHandPresenceConfidence = 0.5
        options.minTrackingConfidence = 0.5
        options.handLandmarkerLiveStreamDelegate = self

        do {
            handLandmarker = try HandLandmarker(options: options)
            print("MotionPlay: Hand Landmarker initialized!")
        } catch {
            print("Hand Landmarker initialization failed: \(error)")
        }
    }

    func detect(
        sampleBuffer: CMSampleBuffer,
        timestampInMilliseconds: Int
    ) {
        guard let handLandmarker else { return }

        do {
            let image = try MPImage(sampleBuffer: sampleBuffer)
            try handLandmarker.detectAsync(
                image: image,
                timestampInMilliseconds: timestampInMilliseconds
            )
        } catch {
            print("Hand detection error: \(error)")
        }
    }

    func handLandmarker(
        _ handLandmarker: HandLandmarker,
        didFinishDetection result: HandLandmarkerResult?,
        timestampInMilliseconds: Int,
        error: Error?
    ) {
        if let error {
            print("Hand detection failed: \(error)")
            DispatchQueue.main.async { [weak self] in
                self?.onHandUpdate?(nil, false)
            }
            return
        }

        guard let landmarks = result?.landmarks.first,
              landmarks.count > 8 else {
            DispatchQueue.main.async { [weak self] in
                self?.onHandUpdate?(nil, false)
            }
            return
        }

        // MediaPipe landmark 4 = thumb tip, 8 = index fingertip.
        let thumbTip = landmarks[4]
        let indexTip = landmarks[8]

        let dx = CGFloat(thumbTip.x - indexTip.x)
        let dy = CGFloat(thumbTip.y - indexTip.y)
        let pinchDistance = hypot(dx, dy)
        let isPinching = pinchDistance < 0.055

        // Front-camera preview is mirrored, so mirror the normalized X coordinate.
        let cursor = CGPoint(
            x: min(1, max(0, 1 - CGFloat(indexTip.x))),
            y: min(1, max(0, CGFloat(indexTip.y)))
        )

        DispatchQueue.main.async { [weak self] in
            self?.onHandUpdate?(cursor, isPinching)
        }
    }
}
