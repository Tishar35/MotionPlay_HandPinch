import Foundation
import AVFoundation
import Combine
import MediaPipeTasksVision
import CoreGraphics

final class CameraManager: NSObject, ObservableObject {

    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(
        label: "com.motionplay.camera.session"
    )

    private let videoQueue = DispatchQueue(
        label: "com.motionplay.camera.frames"
    )

    private let handManager = HandLandmarkerManager()
    private var wasPinching = false

    @Published var isCameraRunning = false
    @Published var cameraError: String?
    @Published var handPointer: CGPoint?
    @Published var isPersonDetected = false
    @Published var isPinching = false
    @Published var pinchEventCount = 0

    override init() {
        super.init()

        handManager.onHandUpdate = { [weak self] point, pinching in
            guard let self else { return }

            self.handPointer = point
            self.isPersonDetected = (point != nil)
            self.isPinching = pinching

            // Trigger exactly once when the fingers close, not on every camera frame.
            if pinching && !self.wasPinching {
                self.pinchEventCount += 1
            }
            self.wasPinching = pinching
        }
    }

    func startCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndStartSession()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.configureAndStartSession()
                } else {
                    DispatchQueue.main.async {
                        self?.cameraError = "Camera permission denied."
                    }
                }
            }

        case .denied, .restricted:
            DispatchQueue.main.async {
                self.cameraError = "Please allow camera access in Settings."
            }

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
                        domain: "MotionPlay",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Front camera not available."]
                    )
                }

                let input = try AVCaptureDeviceInput(device: camera)
                guard self.session.canAddInput(input) else {
                    throw NSError(
                        domain: "MotionPlay",
                        code: 2,
                        userInfo: [NSLocalizedDescriptionKey: "Cannot add camera input."]
                    )
                }
                self.session.addInput(input)

                let output = AVCaptureVideoDataOutput()
                output.videoSettings = [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
                ]
                output.alwaysDiscardsLateVideoFrames = true
                output.setSampleBufferDelegate(self, queue: self.videoQueue)

                guard self.session.canAddOutput(output) else {
                    throw NSError(
                        domain: "MotionPlay",
                        code: 3,
                        userInfo: [NSLocalizedDescriptionKey: "Cannot add video output."]
                    )
                }
                self.session.addOutput(output)
                setupSucceeded = true

            } catch {
                DispatchQueue.main.async {
                    self.cameraError = error.localizedDescription
                }
            }

            self.session.commitConfiguration()

            if setupSucceeded {
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.isCameraRunning = true
                    self.cameraError = nil
                }
            }
        }
    }

    func stopCamera() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
            DispatchQueue.main.async {
                self.isCameraRunning = false
                self.handPointer = nil
                self.isPersonDetected = false
                self.isPinching = false
                self.wasPinching = false
            }
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let milliseconds = Int(CMTimeGetSeconds(timestamp) * 1000)

        handManager.detect(
            sampleBuffer: sampleBuffer,
            timestampInMilliseconds: milliseconds
        )
    }
}
