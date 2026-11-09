import SwiftUI

/// Visible astronaut glove / hand reaching cursor displayed during gameplay.
struct StarCollectorHandCursorView: View {

    let position: CGPoint
    var isPersonDetected: Bool = true
    var isWarning: Bool = false

    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Outer Stardust Glow Ring
            Circle()
                .stroke(
                    isWarning ? Color.red.opacity(0.8) : Color.cyan.opacity(0.7),
                    lineWidth: 3
                )
                .frame(width: 64 * pulseScale, height: 64 * pulseScale)
                .shadow(color: isWarning ? .red : .cyan, radius: 10)

            // Inner Core Target Disk
            Circle()
                .fill(
                    LinearGradient(
                        colors: isWarning ? [Color.red.opacity(0.8), Color.orange.opacity(0.9)] : [Color.white, Color(red: 0.85, green: 0.95, blue: 1.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
                .shadow(color: .black.opacity(0.2), radius: 6)

            // Astronaut Glove Icon
            Image(systemName: "hand.point.up.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(isWarning ? Color.white : Color.blue)
                .offset(y: -2)
        }
        .position(position)
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 0.9)
                    .repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.18
            }
        }
    }
}
