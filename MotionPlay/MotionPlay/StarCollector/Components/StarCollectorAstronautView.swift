import SwiftUI

/// Polished cartoon astronaut character rendered entirely in vector SwiftUI shapes.
/// Features lively floating bobbing, animated visor expressions, and celebration animations.
struct StarCollectorAstronautView: View {

    var emotion: StarCollectorGameManager.AstronautEmotion = .idle
    var size: CGFloat = 110

    @State private var floatOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: -size * 0.08) {
            // Helmet & Head
            ZStack {
                // Helmet Antenna
                VStack(spacing: 0) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: size * 0.1, height: size * 0.1)
                        .shadow(color: .orange, radius: 4)
                    Rectangle()
                        .fill(Color.gray.opacity(0.8))
                        .frame(width: size * 0.03, height: size * 0.12)
                }
                .offset(y: -size * 0.44)

                // Outer White Helmet
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color(red: 0.88, green: 0.90, blue: 0.95)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size * 0.68, height: size * 0.68)
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)

                // Helmet Visor Glass (Glossy dark glass with cyan tint)
                RoundedRectangle(cornerRadius: size * 0.22)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.10, green: 0.15, blue: 0.32),
                                Color(red: 0.05, green: 0.25, blue: 0.38)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.50, height: size * 0.38)
                    .overlay(
                        RoundedRectangle(cornerRadius: size * 0.22)
                            .stroke(Color.cyan.opacity(0.6), lineWidth: 2)
                    )

                // Face / Expression inside visor
                HStack(spacing: size * 0.12) {
                    if emotion == .celebrating {
                        // Happy star eyes!
                        Image(systemName: "star.fill")
                            .font(.system(size: size * 0.10))
                            .foregroundStyle(.yellow)
                        Image(systemName: "star.fill")
                            .font(.system(size: size * 0.10))
                            .foregroundStyle(.yellow)
                    } else if emotion == .warning {
                        // Wide curious eyes
                        Circle()
                            .fill(Color.white)
                            .frame(width: size * 0.09, height: size * 0.09)
                        Circle()
                            .fill(Color.white)
                            .frame(width: size * 0.09, height: size * 0.09)
                    } else {
                        // Cheerful smiling curved eyes
                        Circle()
                            .fill(Color.white.opacity(0.95))
                            .frame(width: size * 0.08, height: size * 0.08)
                        Circle()
                            .fill(Color.white.opacity(0.95))
                            .frame(width: size * 0.08, height: size * 0.08)
                    }
                }
                .offset(y: -size * 0.02)

                // Visor glossy reflection highlight
                Ellipse()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: size * 0.22, height: size * 0.07)
                    .rotationEffect(.degrees(-15))
                    .offset(x: -size * 0.09, y: -size * 0.09)
            }

            // Spacesuit Body & Arms
            ZStack {
                // Backpack Oxygen Tank
                RoundedRectangle(cornerRadius: size * 0.08)
                    .fill(Color.gray.opacity(0.45))
                    .frame(width: size * 0.58, height: size * 0.36)
                    .offset(y: -size * 0.04)

                // Suit Torso
                RoundedRectangle(cornerRadius: size * 0.14)
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color(red: 0.88, green: 0.90, blue: 0.96)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.44, height: size * 0.38)

                // Chest Control Panel Badge
                HStack(spacing: 3) {
                    Circle().fill(Color.cyan).frame(width: size * 0.04, height: size * 0.04)
                    Circle().fill(Color.orange).frame(width: size * 0.04, height: size * 0.04)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: size * 0.12, height: size * 0.04)
                }
                .offset(y: -size * 0.06)

                // Left Arm / Glove
                RoundedRectangle(cornerRadius: size * 0.06)
                    .fill(Color.white)
                    .frame(width: size * 0.12, height: size * 0.24)
                    .overlay(
                        Circle().fill(Color.cyan).frame(width: size * 0.08),
                        alignment: .bottom
                    )
                    .rotationEffect(.degrees(emotion == .celebrating ? -55 : -15))
                    .offset(x: -size * 0.28, y: emotion == .celebrating ? -size * 0.12 : 0)

                // Right Arm / Glove
                RoundedRectangle(cornerRadius: size * 0.06)
                    .fill(Color.white)
                    .frame(width: size * 0.12, height: size * 0.24)
                    .overlay(
                        Circle().fill(Color.cyan).frame(width: size * 0.08),
                        alignment: .bottom
                    )
                    .rotationEffect(.degrees(emotion == .celebrating ? 55 : 15))
                    .offset(x: size * 0.28, y: emotion == .celebrating ? -size * 0.12 : 0)
            }
        }
        .offset(y: floatOffset)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: emotion)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.2)
                    .repeatForever(autoreverses: true)
            ) {
                floatOffset = -8
            }
        }
    }
}
