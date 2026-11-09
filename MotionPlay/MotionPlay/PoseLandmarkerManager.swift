
import Foundation
import AVFoundation
import MediaPipeTasksVision

final class PoseLandmarkerManager: NSObject, PoseLandmarkerLiveStreamDelegate {

    private var poseLandmarker: PoseLandmarker?
    var onPoseXUpdate: ((CGFloat?) -> Void)?

    override init() {
        super.init()
        setupPoseLandmarker()
    }

    // MARK: - Initialize MediaPipe

    private func setupPoseLandmarker() {

        guard let modelPath = Bundle.main.path(
            forResource: "pose_landmarker_lite",
            ofType: "task"
        ) else {
            print("ERROR: Pose model not found in app bundle.")
            return
        }

        let options = PoseLandmarkerOptions()

        options.baseOptions.modelAssetPath = modelPath
        options.runningMode = .liveStream
        options.numPoses = 1

        options.minPoseDetectionConfidence = 0.5
        options.minPosePresenceConfidence = 0.5
        options.minTrackingConfidence = 0.5

        options.poseLandmarkerLiveStreamDelegate = self

        do {
            poseLandmarker = try PoseLandmarker(options: options)
            print("MotionPlay: Pose Landmarker initialized!")
        } catch {
            print("Pose Landmarker initialization failed: \(error)")
        }
    }

    // MARK: - Process Camera Frames

    func detect(
        sampleBuffer: CMSampleBuffer,
        timestampInMilliseconds: Int
    ) {

        guard let poseLandmarker = poseLandmarker else {
            return
        }

        do {
            let image = try MPImage(sampleBuffer: sampleBuffer)

            try poseLandmarker.detectAsync(
                image: image,
                timestampInMilliseconds: timestampInMilliseconds
            )

        } catch {
            print("Pose detection error: \(error)")
        }
    }

    // MARK: - Receive Detection Results

    
    func poseLandmarker(
        _ poseLandmarker: PoseLandmarker,
        didFinishDetection result: PoseLandmarkerResult?,
        timestampInMilliseconds: Int,
        error: Error?
    ) {
        if let error = error {
            print("Detection failed: \(error)")
            return
        }

        guard let result = result,
              let landmarks = result.landmarks.first,
              landmarks.count > 12 else {
            DispatchQueue.main.async { [weak self] in self?.onPoseXUpdate?(nil) }
            return
        }

        print("MotionPlay: \(landmarks.count) landmarks detected")

        let nose = landmarks[0]
        let leftShoulder = landmarks[11]
        let rightShoulder = landmarks[12]
        let leftHip = landmarks[23]
        let rightHip = landmarks[24]
        let bodyCenterX = CGFloat((leftShoulder.x + rightShoulder.x) / 2.0)
        DispatchQueue.main.async { [weak self] in
            self?.onPoseXUpdate?(bodyCenterX)
        }

        print("""
        BODY TRACKING:
        Nose: \(nose.x), \(nose.y)
        Left Shoulder: \(leftShoulder.x), \(leftShoulder.y)
        Right Shoulder: \(rightShoulder.x), \(rightShoulder.y)
        Left Hip: \(leftHip.x), \(leftHip.y)
        Right Hip: \(rightHip.x), \(rightHip.y)
        """)
    }

}

