import SwiftUI

/// Deep cosmic nebula background with animated twinkling stars and floating planets.
struct StarCollectorSpaceBackgroundView: View {

    @State private var animateTwinkle = false
    @State private var planetOffset: CGFloat = 0

    // Fixed random seeds for aesthetic background star positions
    private let backgroundStars: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = [
        (0.08, 0.12, 3, 0.8), (0.22, 0.08, 2, 0.6), (0.35, 0.18, 4, 0.9),
        (0.15, 0.32, 2, 0.5), (0.42, 0.28, 3, 0.7), (0.28, 0.45, 2, 0.6),
        (0.05, 0.62, 3, 0.8), (0.18, 0.75, 4, 0.9), (0.32, 0.88, 2, 0.4),
        (0.55, 0.10, 3, 0.7), (0.72, 0.14, 4, 0.9), (0.88, 0.06, 2, 0.5),
        (0.68, 0.25, 2, 0.6), (0.82, 0.35, 3, 0.8), (0.95, 0.22, 4, 0.9),
        (0.60, 0.48, 2, 0.5), (0.78, 0.58, 3, 0.7), (0.92, 0.65, 2, 0.6),
        (0.52, 0.72, 3, 0.8), (0.65, 0.85, 4, 0.9), (0.85, 0.82, 2, 0.4),
        (0.45, 0.60, 2, 0.5), (0.12, 0.92, 3, 0.7), (0.75, 0.95, 2, 0.6)
    ]

    var body: some View {
        ZStack {
            // Base Deep Navy to Cosmic Violet Gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.06, blue: 0.16),
                    Color(red: 0.08, green: 0.09, blue: 0.24),
                    Color(red: 0.14, green: 0.08, blue: 0.28),
                    Color(red: 0.07, green: 0.05, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Glowing Cosmic Nebula Clouds
            GeometryReader { geo in
                // Purple Nebula Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.purple.opacity(0.28), Color.purple.opacity(0.0)],
                            center: .center,
                            startRadius: 20,
                            endRadius: geo.size.width * 0.45
                        )
                    )
                    .frame(width: geo.size.width * 0.8, height: geo.size.width * 0.8)
                    .position(x: geo.size.width * 0.2, y: geo.size.height * 0.25)
                    .blur(radius: 40)

                // Deep Cyan Nebula Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.cyan.opacity(0.22), Color.blue.opacity(0.0)],
                            center: .center,
                            startRadius: 20,
                            endRadius: geo.size.width * 0.4
                        )
                    )
                    .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)
                    .position(x: geo.size.width * 0.85, y: geo.size.height * 0.7)
                    .blur(radius: 40)

                // Ringed Saturn-like distant planet
                distantPlanetView
                    .position(x: geo.size.width * 0.88, y: geo.size.height * 0.18)

                // Pastel Mini Moon
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.95, green: 0.90, blue: 0.75), Color(red: 0.80, green: 0.70, blue: 0.55)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: .orange.opacity(0.3), radius: 10)
                    .position(x: geo.size.width * 0.12, y: geo.size.height * 0.82)

                // Twinkling Background Stars
                ForEach(0..<backgroundStars.count, id: \.self) { idx in
                    let star = backgroundStars[idx]
                    Circle()
                        .fill(Color.white)
                        .frame(width: star.size, height: star.size)
                        .position(x: star.x * geo.size.width, y: star.y * geo.size.height)
                        .opacity(animateTwinkle ? star.opacity : (star.opacity * 0.4))
                        .animation(
                            .easeInOut(duration: Double.random(in: 1.2...2.6))
                                .repeatForever(autoreverses: true)
                                .delay(Double(idx) * 0.08),
                            value: animateTwinkle
                        )
                }
            }
        }
        .onAppear {
            animateTwinkle = true
        }
    }

    private var distantPlanetView: some View {
        ZStack {
            // Planet body
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.7, green: 0.45, blue: 0.85), Color(red: 0.35, green: 0.2, blue: 0.55)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 58, height: 58)
                .shadow(color: .purple.opacity(0.4), radius: 12)

            // Planet rings
            Ellipse()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.7), Color.purple.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 4
                )
                .frame(width: 90, height: 28)
                .rotationEffect(.degrees(-22))
        }
    }
}
