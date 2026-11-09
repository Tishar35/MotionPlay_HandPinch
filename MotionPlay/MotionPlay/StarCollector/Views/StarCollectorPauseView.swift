import SwiftUI

/// Screen E: Frosted glass pause menu stopping timer, physics, and collisions.
struct StarCollectorPauseView: View {

    let onResume: () -> Void
    let onRestart: () -> Void
    let onExit: () -> Void

    var body: some View {
        ZStack {
            // Dark Frosted Backdrop
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)

            VStack(spacing: 24) {

                // Pause Icon & Title
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.cyan.opacity(0.2))
                            .frame(width: 76, height: 76)
                        Image(systemName: "pause.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.cyan)
                    }

                    Text("Mission Paused")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Take a breath, astronaut! Ready when you are.")
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.8))
                }

                // Action Buttons
                VStack(spacing: 14) {
                    // Resume Button (Prominent)
                    Button(action: onResume) {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                            Text("Resume Game")
                        }
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.95, green: 0.85, blue: 0.35), Color(red: 1.0, green: 0.70, blue: 0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }

                    // Restart Button
                    Button(action: onRestart) {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Restart Mission")
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }

                    // Exit Activity Button
                    Button(action: onExit) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle")
                            Text("Exit to Universe")
                        }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.red.opacity(0.9))
                        .padding(.top, 6)
                    }
                }
                .frame(maxWidth: 320)
            }
            .padding(32)
            .background(Color(red: 0.08, green: 0.10, blue: 0.22).opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.15), lineWidth: 1.5))
            .shadow(color: .black.opacity(0.5), radius: 25)
        }
    }
}
