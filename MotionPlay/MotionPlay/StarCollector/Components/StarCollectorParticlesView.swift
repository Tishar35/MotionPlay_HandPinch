import SwiftUI

/// Animated cosmic spark and ring burst emitted when a celestial target is collected.
struct StarCollectorParticlesView: View {

    let center: CGPoint
    var color: Color = .cyan

    @State private var particleScale: CGFloat = 0.2
    @State private var particleOpacity: Double = 1.0
    @State private var ringRadius: CGFloat = 10

    private let angles: [Double] = [0, 45, 90, 135, 180, 225, 270, 315]

    var body: some View {
        ZStack {
            // Expanding Starlight Shockwave Ring
            Circle()
                .stroke(color.opacity(particleOpacity), lineWidth: 3)
                .frame(width: ringRadius * 2, height: ringRadius * 2)

            // Radiating Stardust Sparks
            ForEach(0..<angles.count, id: \.self) { idx in
                let angle = angles[idx] * (.pi / 180)
                let distance = ringRadius * 0.95
                let px = cos(angle) * distance
                let py = sin(angle) * distance

                Image(systemName: "sparkle")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.yellow)
                    .scaleEffect(particleScale)
                    .opacity(particleOpacity)
                    .offset(x: px, y: py)
            }
        }
        .position(center)
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeOut(duration: 0.55)) {
                ringRadius = 75
                particleScale = 1.3
                particleOpacity = 0.0
            }
        }
    }
}
