import SwiftUI

/// Renders a floating space target star with glowing auras, breathing animations, and shake feedback.
struct StarCollectorStarView: View {

    let star: StarCollectorStar

    var body: some View {
        ZStack {
            if star.type == .collectibleBlue {
                blueCollectibleView
            } else {
                redDistractorView
            }
        }
        .frame(width: star.size, height: star.size)
        .scaleEffect(star.scale)
        .opacity(star.opacity)
        .rotationEffect(.degrees(star.rotationAngle))
        .modifier(StarCollectorShakeEffect(animatableData: star.isWarning ? 1 : 0))
    }

    // MARK: - Blue Collectible Star
    private var blueCollectibleView: some View {
        ZStack {
            // Pulsing Outer Aura Halo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.cyan.opacity(0.45 + 0.15 * sin(star.pulsePhase)),
                            Color.blue.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: star.size * 0.15,
                        endRadius: star.size * 0.65
                    )
                )
                .frame(width: star.size * 1.35, height: star.size * 1.35)

            // Outer Starlight Sparkle Diamond
            DiamondShape()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.8), Color.cyan.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: star.size * 0.95, height: star.size * 0.95)
                .rotationEffect(.degrees(45))

            // Main Star Shape
            Image(systemName: "star.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.85, green: 0.95, blue: 1.0),
                            Color(red: 0.20, green: 0.65, blue: 1.0),
                            Color(red: 0.10, green: 0.35, blue: 0.90)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .cyan.opacity(0.8), radius: 10)
                .overlay(
                    Image(systemName: "star")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.white.opacity(0.7))
                )
                .frame(width: star.size * 0.78, height: star.size * 0.78)

            // Core Sparkle Highlight
            Circle()
                .fill(Color.white)
                .frame(width: star.size * 0.15, height: star.size * 0.15)
                .shadow(color: .white, radius: 4)
        }
    }

    // MARK: - Red Distractor Star
    private var redDistractorView: some View {
        ZStack {
            // Soft Warning Halo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.red.opacity(star.isWarning ? 0.65 : 0.30),
                            Color.red.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: star.size * 0.15,
                        endRadius: star.size * 0.60
                    )
                )
                .frame(width: star.size * 1.25, height: star.size * 1.25)

            // Main Distractor Star
            Image(systemName: "star.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.45, blue: 0.45),
                            Color(red: 0.92, green: 0.15, blue: 0.15),
                            Color(red: 0.60, green: 0.05, blue: 0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .red.opacity(0.6), radius: 8)
                .overlay(
                    Image(systemName: "star")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.white.opacity(0.5))
                )
                .frame(width: star.size * 0.72, height: star.size * 0.72)

            // Warning Icon overlay on distractor
            Image(systemName: "xmark")
                .font(.system(size: star.size * 0.22, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.75))
        }
    }
}

/// Simple diamond polygon for celestial flair.
struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

/// Shake animation effect for contact warning feedback.
struct StarCollectorShakeEffect: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = 12 * sin(animatableData * .pi * 8)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
