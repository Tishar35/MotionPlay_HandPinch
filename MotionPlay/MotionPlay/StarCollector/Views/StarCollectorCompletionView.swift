import SwiftUI

/// Screen F: Celebratory completion screen summarizing mission accomplishments and Fizee Stars.
struct StarCollectorCompletionView: View {

    let stats: StarCollectorGameStats
    let onPlayAgain: () -> Void
    let onBackToUniverse: () -> Void

    @State private var starPopIndex: Int = 0
    @State private var trophyScale: CGFloat = 0.5
    @State private var trophyOpacity: Double = 0.0

    var body: some View {
        ZStack {
            StarCollectorSpaceBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {

                    // Top Mission Badge
                    Text("MISSION ACCOMPLISHED!")
                        .font(.system(size: 13, weight: .bold))
                        .tracking(3)
                        .foregroundStyle(.cyan)
                        .padding(.top, 20)

                    // Celebratory Character / Trophy Header
                    VStack(spacing: 8) {
                        StarCollectorAstronautView(emotion: .celebrating, size: 130)

                        Text(stats.blueStarsCollected >= stats.targetBlueStars ? "Spectacular Explorer!" : "Fantastic Effort!")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color(red: 0.95, green: 0.88, blue: 0.45)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .orange.opacity(0.6), radius: 10)

                        Text("You explored the cosmos and helped gather the lost stars.")
                            .font(.system(size: 15))
                            .foregroundStyle(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                    }

                    // Fizee Stars Reward Row (1 to 3 stars)
                    VStack(spacing: 8) {
                        Text("FIZEE STARS EARNED")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(.yellow)

                        HStack(spacing: 16) {
                            ForEach(1...3, id: \.self) { index in
                                let isEarned = index <= stats.fizeeStarsEarned
                                ZStack {
                                    Circle()
                                        .fill(isEarned ? Color.yellow.opacity(0.2) : Color.white.opacity(0.05))
                                        .frame(width: 60, height: 60)

                                    Image(systemName: isEarned ? "star.fill" : "star")
                                        .font(.system(size: 34))
                                        .foregroundStyle(isEarned ? Color.yellow : Color.white.opacity(0.25))
                                        .shadow(color: isEarned ? .yellow.opacity(0.8) : .clear, radius: 8)
                                }
                                .scaleEffect(index <= starPopIndex ? 1.0 : 0.2)
                                .opacity(index <= starPopIndex ? 1.0 : 0.0)
                            }
                        }
                    }
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 22))

                    // Mission Statistics Cards
                    HStack(spacing: 12) {
                        statCard(
                            title: "Blue Stars",
                            value: "\(stats.blueStarsCollected)/\(stats.targetBlueStars)",
                            icon: "star.fill",
                            color: .cyan
                        )

                        statCard(
                            title: "Time Taken",
                            value: stats.timeTakenFormatted,
                            icon: "clock.fill",
                            color: .orange
                        )

                        statCard(
                            title: "Focus",
                            value: "\(stats.accuracyPercentage)%",
                            icon: "target",
                            color: .green
                        )
                    }

                    // Encouragement Note
                    Text("Every reach builds stronger hand-eye coordination and body balance!")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    // Action Buttons
                    VStack(spacing: 14) {
                        Button(action: onPlayAgain) {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Play Again")
                            }
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 0.95, green: 0.85, blue: 0.35), Color(red: 1.0, green: 0.70, blue: 0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(color: .orange.opacity(0.4), radius: 10, y: 4)
                        }

                        Button(action: onBackToUniverse) {
                            HStack(spacing: 8) {
                                Image(systemName: "house.fill")
                                Text("Back to Universe")
                            }
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.2), lineWidth: 1))
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: 620)
            }
        }
        .onAppear {
            animateCelebration()
        }
    }

    private func animateCelebration() {
        // Sequentially pop in the Fizee Stars
        for i in 1...stats.fizeeStarsEarned {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.28) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    starPopIndex = i
                }
            }
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.black.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}
