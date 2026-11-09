
import SwiftUI
import AVFoundation

struct ContentView: View {

    @StateObject private var cameraManager = CameraManager()

    var body: some View {

        ZStack {

            Color.black
                .ignoresSafeArea()

            #if os(iOS)
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()
            #endif

            VStack {

                HStack {
                    Text("MOTIONPLAY")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Spacer()

                    Circle()
                        .fill(cameraManager.isCameraRunning ? .green : .red)
                        .frame(width: 12, height: 12)

                    Text(cameraManager.isCameraRunning ? "LIVE" : "OFFLINE")
                        .foregroundColor(.white)
                        .font(.caption.bold())
                }
                .padding()

                Spacer()

                if let error = cameraManager.cameraError {
                    Text(error)
                        .foregroundColor(.white)
                        .padding()
                }

                Button {
                    if cameraManager.isCameraRunning {
                        cameraManager.stopCamera()
                    } else {
                        cameraManager.startCamera()
                    }
                } label: {
                    Text(cameraManager.isCameraRunning
                         ? "Stop Camera"
                         : "Start Camera")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
        }
    }
}

#if os(iOS)


struct CameraPreview: UIViewRepresentable {

    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()

        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill

        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.videoPreviewLayer.session = session
        uiView.configureRotationIfNeeded()
        
    }
}

final class PreviewView: UIView {

    private var rotationCoordinator:
        AVCaptureDevice.RotationCoordinator?

    private var previewObservation: NSKeyValueObservation?
    private var captureObservation: NSKeyValueObservation?

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    override func layoutSubviews() {
        super.layoutSubviews()

        guard let connection = videoPreviewLayer.connection else {
            return
        }

        let angle: CGFloat

        if bounds.width > bounds.height {
            angle = 90
        } else {
            angle = 0
        }

        if connection.isVideoRotationAngleSupported(angle) {
            connection.videoRotationAngle = angle
        }
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()

        guard window != nil else { return }

        configureRotationIfNeeded()    }

    func configureRotationIfNeeded() {
        guard rotationCoordinator == nil else { return }

        guard
            let session = videoPreviewLayer.session,
            let input = session.inputs.compactMap({
                $0 as? AVCaptureDeviceInput
            }).first
        else {
            return
        }

        let coordinator = AVCaptureDevice.RotationCoordinator(
            device: input.device,
            previewLayer: videoPreviewLayer
        )

        rotationCoordinator = coordinator

        applyPreviewRotation(
            coordinator.videoRotationAngleForHorizonLevelPreview
        )

        applyCaptureRotation(
            coordinator.videoRotationAngleForHorizonLevelCapture
        )

        previewObservation = coordinator.observe(
            \.videoRotationAngleForHorizonLevelPreview,
            options: [.new]
        ) { [weak self] _, change in

            guard let angle = change.newValue else { return }

            DispatchQueue.main.async {
                self?.applyPreviewRotation(angle)
            }
        }

        captureObservation = coordinator.observe(
            \.videoRotationAngleForHorizonLevelCapture,
            options: [.new]
        ) { [weak self] _, change in

            guard let angle = change.newValue else { return }

            DispatchQueue.main.async {
                self?.applyCaptureRotation(angle)
            }
        }
    }

    private func applyPreviewRotation(_ angle: CGFloat) {

        guard let connection = videoPreviewLayer.connection else {
            return
        }

        if connection.isVideoRotationAngleSupported(angle) {
            connection.videoRotationAngle = angle
        }
    }

    private func applyCaptureRotation(_ angle: CGFloat) {

        guard let session = videoPreviewLayer.session else {
            return
        }

        for output in session.outputs {

            guard let connection = output.connection(with: .video) else {
                continue
            }

            if connection.isVideoRotationAngleSupported(angle) {
                connection.videoRotationAngle = angle
            }
        }
    }
}


#endif

#Preview {
    ContentView()
}
