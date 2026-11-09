import SwiftUI

/// Screen D: Active floating space environment for Star Collector gameplay.
struct StarCollectorGameView: View {

    @ObservedObject var viewModel: StarCollectorViewModel
    let onPause: () -> Void

    @State private var lastTickTime: Date = Date()
    @State private var activeParticleBursts: [(id: UUID, position: CGPoint)] = []

    var body: some View {
        GeometryReader { geometry in
            let areaSize = geometry.size

            ZStack {
                // Background
                StarCollectorSpaceBackgroundView()

                // Star Targets Layer (TimelineView drives physics and collisions)
                TimelineView(.animation) { timeline in
                    CanvasContent(
                        timeline: timeline.date,
                        areaSize: areaSize
                    )
                }

                // Particle Bursts Layer
                ForEach(activeParticleBursts, id: \.id) { burst in
                    StarCollectorParticlesView(center: burst.position, color: .cyan)
                }

                // Hand Reach Pointer Cursor
                if let normPoint = viewModel.activePointer {
                    let screenX = normPoint.x * areaSize.width
                    let screenY = normPoint.y * areaSize.height
                    StarCollectorHandCursorView(
                        position: CGPoint(x: screenX, y: screenY),
                        isPersonDetected: viewModel.isPersonDetected,
                        isWarning: viewModel.gameManager.distractorWarningActive
                    )
                }

                // Companion Astronaut (bottom leading corner)
                VStack {
                    Spacer()
                    HStack {
                        StarCollectorAstronautView(
                            emotion: viewModel.gameManager.astronautEmotion,
                            size: 110
                        )
                        .padding(.leading, 24)
                        .padding(.bottom, 20)

                        if viewModel.gameManager.distractorWarningActive {
                            Text("Oops! Ignore red stars!")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.red)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.9))
                                .clipShape(Capsule())
                                .transition(.scale.combined(with: .opacity))
                        }

                        Spacer()
                    }
                }
                .allowsHitTesting(false)

                // PIP Camera Preview (Camera Mode only, bottom trailing corner)
                if viewModel.selectedMode == .camera {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ZStack(alignment: .bottomLeading) {
                                CameraPreview(session: viewModel.cameraProvider.session)
                                    .frame(width: 140, height: 95)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                                    )
                                    .shadow(radius: 6)

                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(viewModel.cameraProvider.isPersonDetected ? Color.green : Color.orange)
                                        .frame(width: 6, height: 6)
                                    Text(viewModel.cameraProvider.isPersonDetected ? "Hand" : "Look")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Capsule())
                                .padding(6)
                            }
                            .padding(.trailing, 24)
                            .padding(.bottom, 20)
                        }
                    }
                    .allowsHitTesting(false)
                }

                // Top HUD Bar
                VStack {
                    StarCollectorHUDView(
                        stats: viewModel.gameManager.stats,
                        mode: viewModel.selectedMode,
                        isPersonDetected: viewModel.isPersonDetected,
                        onPause: onPause
                    )
                    Spacer()
                }
            }
            .contentShape(Rectangle())
            // Gesture for touch & mouse input in Demo Mode (and touch fallback in Camera Mode)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        viewModel.updateTouchInput(screenPoint: value.location, viewSize: areaSize)
                    }
            )
            .onChange(of: viewModel.gameManager.recentCollectedStarPosition) { _, newPos in
                guard let newPos else { return }
                let screenPos = CGPoint(x: newPos.x * areaSize.width, y: newPos.y * areaSize.height)
                let burstId = UUID()
                activeParticleBursts.append((id: burstId, position: screenPos))

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    activeParticleBursts.removeAll(where: { $0.id == burstId })
                }
            }
        }
    }

    @ViewBuilder
    private func CanvasContent(timeline: Date, areaSize: CGSize) -> some View {
        let delta = min(0.05, max(0.001, timeline.timeIntervalSince(lastTickTime)))

        // Render visible floating stars
        ZStack {
            ForEach(viewModel.gameManager.stars) { star in
                let screenX = star.position.x * areaSize.width
                let screenY = star.position.y * areaSize.height

                StarCollectorStarView(star: star)
                    .position(x: screenX, y: screenY)
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            lastTickTime = timeline
        }
        .onChange(of: timeline) { _, newTime in
            let dt = min(0.05, max(0.001, newTime.timeIntervalSince(lastTickTime)))
            lastTickTime = newTime

            // Advance engine physics & collisions
            viewModel.gameManager.tick(deltaTime: dt)
            viewModel.gameManager.processPointer(
                at: viewModel.activePointer,
                areaSize: areaSize
            )
        }
    }
}
