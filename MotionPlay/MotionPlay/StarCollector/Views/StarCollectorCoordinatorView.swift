import SwiftUI

/// Root coordinator managing the 6-screen flow for the Star Collector activity.
struct StarCollectorCoordinatorView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = StarCollectorViewModel()

    var body: some View {
        ZStack {
            switch viewModel.phase {
            case .intro:
                StarCollectorIntroView(
                    onStart: { viewModel.goToSetup() },
                    onBack: { dismiss() }
                )
                .transition(.opacity)

            case .setup:
                StarCollectorSetupView(
                    selectedMode: $viewModel.selectedMode,
                    cameraProvider: viewModel.cameraProvider,
                    onProceedToCountdown: { viewModel.startCountdown() },
                    onBack: { viewModel.goToIntro() }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))

            case .countdown:
                StarCollectorCountdownView(count: viewModel.countdownCount)
                    .transition(.opacity)

            case .playing:
                StarCollectorGameView(
                    viewModel: viewModel,
                    onPause: { viewModel.pauseGame() }
                )
                .transition(.opacity)

            case .paused:
                ZStack {
                    // Keep gameplay visible underneath frosted blur
                    StarCollectorGameView(
                        viewModel: viewModel,
                        onPause: {}
                    )

                    StarCollectorPauseView(
                        onResume: { viewModel.resumeGame() },
                        onRestart: { viewModel.restartGame() },
                        onExit: { dismiss() }
                    )
                }
                .transition(.opacity)

            case .completed:
                StarCollectorCompletionView(
                    stats: viewModel.gameManager.stats,
                    onPlayAgain: { viewModel.restartGame() },
                    onBackToUniverse: { dismiss() }
                )
                .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.onDismissToHome = { dismiss() }
        }
        .onDisappear {
            viewModel.exitActivity()
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.phase)
    }
}
