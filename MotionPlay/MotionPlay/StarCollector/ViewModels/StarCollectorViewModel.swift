import SwiftUI
import Combine

/// Main ViewModel binding the tracking providers, game engine, and UI navigation flow.
final class StarCollectorViewModel: ObservableObject {

    @Published var phase: StarCollectorPhase = .intro
    @Published var selectedMode: StarCollectorTrackingMode = .demo
    @Published var countdownCount: Int = 3

    // Expose game manager for state observation
    @Published var gameManager = StarCollectorGameManager()

    // Tracking providers
    let mockProvider = StarCollectorMockTrackingProvider()
    let cameraProvider = StarCollectorCameraProvider()

    private var cancellables = Set<AnyCancellable>()
    private var countdownTimer: AnyCancellable?

    var onDismissToHome: (() -> Void)?

    init() {
        setupBindings()
    }

    private func setupBindings() {
        // Forward completion from game manager
        gameManager.onGameCompleted = { [weak self] _ in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                self?.phase = .completed
                self?.stopActiveTracking()
            }
        }

        // Observe mock provider updates
        mockProvider.$pointerPosition
            .sink { [weak self] point in
                guard let self, self.selectedMode == .demo, self.phase == .playing else { return }
                self.forwardPointerToGame(point)
            }
            .store(in: &cancellables)

        // Observe camera provider updates
        cameraProvider.$pointerPosition
            .sink { [weak self] point in
                guard let self, self.selectedMode == .camera, self.phase == .playing else { return }
                self.forwardPointerToGame(point)
            }
            .store(in: &cancellables)
    }

    var activePointer: CGPoint? {
        selectedMode == .demo ? mockProvider.pointerPosition : cameraProvider.pointerPosition
    }

    var isPersonDetected: Bool {
        selectedMode == .demo ? mockProvider.isPersonDetected : cameraProvider.isPersonDetected
    }

    private func forwardPointerToGame(_ point: CGPoint?) {
        guard let point else { return }
        // The game area size is computed dynamically in the view geometry
    }

    // MARK: - Flow Controls

    func goToIntro() {
        phase = .intro
        stopActiveTracking()
    }

    func goToSetup() {
        phase = .setup
    }

    func startCountdown() {
        phase = .countdown
        countdownCount = 3
        StarCollectorAudioService.shared.playCountdownTick()

        countdownTimer?.cancel()
        countdownTimer = Timer.publish(every: 0.9, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.countdownCount > 1 {
                    self.countdownCount -= 1
                    StarCollectorAudioService.shared.playCountdownTick()
                } else if self.countdownCount == 1 {
                    self.countdownCount = 0 // "GO!"
                    StarCollectorAudioService.shared.playBlastoff()
                } else {
                    self.countdownTimer?.cancel()
                    self.countdownTimer = nil
                    self.beginGameplay()
                }
            }
    }

    private func beginGameplay() {
        phase = .playing
        gameManager.startSession()
        startActiveTracking()
    }

    func pauseGame() {
        guard phase == .playing else { return }
        phase = .paused
    }

    func resumeGame() {
        guard phase == .paused else { return }
        phase = .playing
    }

    func restartGame() {
        gameManager.reset()
        startCountdown()
    }

    func exitActivity() {
        stopActiveTracking()
        gameManager.reset()
        onDismissToHome?()
    }

    private func startActiveTracking() {
        if selectedMode == .demo {
            mockProvider.startTracking()
        } else {
            cameraProvider.startTracking()
        }
    }

    private func stopActiveTracking() {
        mockProvider.stopTracking()
        cameraProvider.stopTracking()
    }

    func updateTouchInput(screenPoint: CGPoint, viewSize: CGSize) {
        if selectedMode == .demo {
            mockProvider.updateTouch(screenPoint: screenPoint, viewSize: viewSize)
        } else {
            // Also provide touch fallback in camera mode
            guard viewSize.width > 0, viewSize.height > 0 else { return }
            let norm = CGPoint(x: screenPoint.x / viewSize.width, y: screenPoint.y / viewSize.height)
            cameraProvider.updateTouchFallback(normalizedPoint: norm)
        }
    }
}
