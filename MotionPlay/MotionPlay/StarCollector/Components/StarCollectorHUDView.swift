import SwiftUI

/// Floating glassmorphic Heads-Up-Display (HUD) for active gameplay.
struct StarCollectorHUDView: View {

    let stats: StarCollectorGameStats
    let mode: StarCollectorTrackingMode
    let isPersonDetected: Bool
    let onPause: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Pause Button
            Button(action: onPause) {
                HStack(spacing: 6) {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text("Pause")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
            }

            // Mode & Detection Pill
            HStack(spacing: 6) {
                Circle()
                    .fill(isPersonDetected ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                Text(mode == .demo ? "Demo Mode" : (isPersonDetected ? "Hand Detected" : "Raise Hand"))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.35))
            .clipShape(Capsule())

            Spacer()

            // Stars Collected Counter
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.yellow)
                    .shadow(color: .yellow.opacity(0.6), radius: 4)

                Text("\(stats.blueStarsCollected) / \(stats.targetBlueStars)")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.cyan.opacity(0.4), lineWidth: 1.5))

            // Timer Display
            HStack(spacing: 6) {
                Image(systemName: "timer")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(stats.timeRemaining <= 15 ? .red : .cyan)

                Text(formatSeconds(Int(stats.timeRemaining)))
                    .font(.system(size: 18, weight: .heavy, design: .monospaced))
                    .foregroundStyle(stats.timeRemaining <= 15 ? .red : .white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(
                    stats.timeRemaining <= 15 ? Color.red.opacity(0.8) : Color.white.opacity(0.2),
                    lineWidth: 1
                )
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
    }

    private func formatSeconds(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
