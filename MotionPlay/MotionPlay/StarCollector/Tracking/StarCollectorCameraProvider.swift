import Foundation
import AVFoundation
import CoreGraphics
import Combine
import MediaPipeTasksVision

/// Separate, safe camera and vision tracking provider for Star Collector.
/// Operates independently from `CameraManager` to ensure zero regressions for Move & Match.
final class StarCollectorCameraProvider: NSObject, StarCollectorTrackingProvider, AVCaptureVideoDataOutputSampleBufferDelegate, HandLandmarkerLiveStreamDelegate, PoseLandmarkerLiveStreamDelegate {

    @Published private(set) var pointerPosition: CGPoint?
    @Published private(set) var isTrackingActive: Bool = false
    @Published private(set) var isPersonDetected: Bool = false
    @Published private(set) var cameraError: String?
    @Published private(set) var authorizationStatus: AVAuthorizationStatus = .notDetermined

    let mode: StarCollectorTrackingMode = .camera
    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "com.motionplay.starcollector.session")
    private let videoQueue = DispatchQueue(label: "com.motionplay.starcollector.video")

    // MediaPipe Hand and Pose fallbacks
    private var handLandmarker: HandLandmarker?
    private var poseLandmarker: PoseLandmarker?
    private var isUsingPoseFallback = false
    private var isLandmarkerSetup = false

    override init() {
        super.init()
        self.authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        // MediaPipe landmarkers and camera sessions are deliberately deferred
        // until tracking is explicitly requested on a background queue.
    }

    private func ensureLandmarkersSetup() {
        guard !isLandmarkerSetup else { return }
        isLandmarkerSetup = true
        setupLandmarkers()
    }

    private func setupLandmarkers() {
        // Try Hand Landmarker first if task file is available
        if let handModelPath = Bundle.main.path(forResource: "hand_landmarker", ofType: "task") {
            let options = HandLandmarkerOptions()
            options.baseOptions.modelAssetPath = handModelPath
            options.runningMode = .liveStream
            options.numHands = 1
            options.minHandDetectionConfidence = 0.5
            options.handLandmarkerLiveStreamDelegate = self
            do {
                handLandmarker = try HandLandmarker(options: options)
                print("StarCollector: Hand Landmarker initialized successfully.")
                return
            } catch {
                print("StarCollector: Hand Landmarker initialization notice: \(error)")
            }
        }

        // Fallback to Pose Landmarker (bundled in project: pose_landmarker_lite.task)
        if let poseModelPath = Bundle.main.path(forResource: "pose_landmarker_lite", ofType: "task") {
            let options = PoseLandmarkerOptions()
            options.baseOptions.modelAssetPath = poseModelPath
            options.runningMode = .liveStream
            options.numPoses = 1
            options.minPoseDetectionConfidence = 0.5
            options.poseLandmarkerLiveStreamDelegate = self
            do {
                poseLandmarker = try PoseLandmarker(options: options)
                isUsingPoseFallback = true
                print("StarCollector: Pose Landmarker initialized as reaching hand tracker.")
            } catch {
                print("StarCollector: Pose Landmarker initialization notice: \(error)")
            }
        }
    }

    func startTracking() {
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authorizationStatus {
        case .authorized:
            configureAndStartSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.authorizationStatus = granted ? .authorized : .denied
                    if granted {
                        self?.configureAndStartSession()
                    } else {
                        self?.cameraError = "Camera access denied. You can still play using Demo Mode!"
                    }
                }
            }
        case .denied, .restricted:
            cameraError = "Camera access is restricted. Switch to Demo Mode to play!"
        @unknown default:
            break
        }
    }

    private func configureAndStartSession() {
        sessionQueue.async { [weak self] in
            guard let self, !self.session.isRunning else { return }

            self.session.beginConfiguration()
            self.session.sessionPreset = .high
            var setupSucceeded = false

            do {
                guard let camera = AVCaptureDevice.default(
                    .builtInWideAngleCamera,
                    for: .video,
                    position: .front
                ) else {
                    throw NSError(
                        domain: "StarCollectorCamera",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Front camera unavailable (e.g. running in Simulator). Switch to Demo Mode!"]
                    )
                }

                let input = try AVCaptureDeviceInput(device: camera)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }

                let output = AVCaptureVideoDataOutput()
                output.videoSettings = [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
                ]
                output.alwaysDiscardsLateVideoFrames = true
                output.setSampleBufferDelegate(self, queue: self.videoQueue)

                if self.session.canAddOutput(output) {
                    self.session.addOutput(output)
                    self.ensureLandmarkersSetup()
                    setupSucceeded = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.cameraError = error.localizedDescription
                }
            }

            self.session.commitConfiguration()

            if setupSucceeded {
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.isTrackingActive = true
                    self.cameraError = nil
                }
            }
        }
    }

    func stopTracking() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
            DispatchQueue.main.async {
                self.isTrackingActive = false
                self.isPersonDetected = false
                self.pointerPosition = nil
            }
        }
    }

    // Touch override fallback even in camera mode
    func updateTouchFallback(normalizedPoint: CGPoint) {
        pointerPosition = normalizedPoint
        isPersonDetected = true
    }

    // MARK: - Video Frame Capture Output
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let milliseconds = Int(CMTimeGetSeconds(timestamp) * 1000)

        guard let image = try? MPImage(sampleBuffer: sampleBuffer) else { return }

        if let handLandmarker {
            try? handLandmarker.detectAsync(image: image, timestampInMilliseconds: milliseconds)
        } else if let poseLandmarker {
            try? poseLandmarker.detectAsync(image: image, timestampInMilliseconds: milliseconds)
        }
    }

    // MARK: - MediaPipe Hand Landmarker Delegate
    func handLandmarker(
        _ handLandmarker: HandLandmarker,
        didFinishDetection result: HandLandmarkerResult?,
        timestampInMilliseconds: Int,
        error: Error?
    ) {
        if let error {
            print("StarCollector: Hand detection error: \(error)")
            return
        }

        guard let landmarks = result?.landmarks.first, landmarks.count > 8 else {
            DispatchQueue.main.async { [weak self] in
                self?.isPersonDetected = false
            }
            return
        }

        // Landmark 8 = Index fingertip
        let tip = landmarks[8]
        // Mirror X for front camera
        let mirroredX = min(1.0, max(0.0, 1.0 - CGFloat(tip.x)))
        let clampedY = min(1.0, max(0.0, CGFloat(tip.y)))

        DispatchQueue.main.async { [weak self] in
            self?.isPersonDetected = true
            self?.pointerPosition = CGPoint(x: mirroredX, y: clampedY)
        }
    }

    // MARK: - MediaPipe Pose Landmarker Fallback Delegate
    func poseLandmarker(
        _ poseLandmarker: PoseLandmarker,
        didFinishDetection result: PoseLandmarkerResult?,
        timestampInMilliseconds: Int,
        error: Error?
    ) {
        if let error {
            print("StarCollector: Pose detection error: \(error)")
            return
        }

        guard let landmarks = result?.landmarks.first, landmarks.count > 20 else {
            DispatchQueue.main.async { [weak self] in
                self?.isPersonDetected = false
            }
            return
        }

        // Landmark 15 = Left wrist, 16 = Right wrist
        // Landmark 19 = Left index, 20 = Right index
        let leftHandY = landmarks[19].y
        let rightHandY = landmarks[20].y

        // Pick whichever hand is reaching higher (lower Y in vision coordinates)
        let chosenHand = (leftHandY < rightHandY) ? landmarks[19] : landmarks[20]

        // Mirror X for front camera preview
        let mirroredX = min(1.0, max(0.0, 1.0 - CGFloat(chosenHand.x)))
        let clampedY = min(1.0, max(0.0, CGFloat(chosenHand.y)))

        DispatchQueue.main.async { [weak self] in
            self?.isPersonDetected = true
            self?.pointerPosition = CGPoint(x: mirroredX, y: clampedY)
        }
    }
}
