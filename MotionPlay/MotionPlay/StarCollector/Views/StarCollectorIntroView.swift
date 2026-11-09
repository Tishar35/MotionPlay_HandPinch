import SwiftUI

/// Screen A: Space-themed introduction for Star Collector.
struct StarCollectorIntroView: View {

    let onStart: () -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            StarCollectorSpaceBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Top Navigation Bar
                    HStack {
                        Button(action: onBack) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                Text("Universe")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        }

                        Spacer()

                        Text("LEVEL 1")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(.cyan)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color.cyan.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .padding(.top, 10)

                    // Hero Header Card
                    VStack(spacing: 12) {
                        Text("UNIVERSE • CHAPTER 1: LOST STARS")
                            .font(.system(size: 13, weight: .bold))
                            .tracking(2.5)
                            .foregroundStyle(.cyan)

                        Text("Star Collector")
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color(red: 0.85, green: 0.95, blue: 1.0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .cyan.opacity(0.5), radius: 10)

                        Text("Become a space explorer and gather the lost blue stars!")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                    }

                    // Astronaut Character Illustration
                    StarCollectorAstronautView(emotion: .idle, size: 140)
                        .padding(.vertical, 10)

                    // Mission Story Box
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.title3)
                                .foregroundStyle(.yellow)
                            Text("Help us collect the lost stars!")
                                .font(.system(size: 19, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }

                        Text("Blue stars are scattered throughout deep space. Reach out with your hand to catch the blue stars, but watch out for the tricky red distractor stars!")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.85))
                            .lineSpacing(4)
                    }
                    .padding(22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )

                    // Instructions Cards
                    VStack(spacing: 12) {
                        instructionRow(
                            icon: "hand.point.up.fill",
                            color: .cyan,
                            title: "Reach & Touch",
                            subtitle: "Move your hand towards glowing blue stars to collect them."
                        )

                        instructionRow(
                            icon: "star.fill",
                            color: .yellow,
                            title: "Goal: 8 Blue Stars",
                            subtitle: "Collect all 8 blue stars before the 60-second timer runs out."
                        )

                        instructionRow(
                            icon: "xmark.circle.fill",
                            color: .red,
                            title: "Avoid Red Stars",
                            subtitle: "Red stars are cosmic distractors — leave them floating!"
                        )
                    }

                    // Start Mission Action Button
                    Button(action: onStart) {
                        HStack(spacing: 12) {
                            Text("Start Mission")
                                .font(.system(size: 19, weight: .bold, design: .rounded))
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 22))
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.95, green: 0.85, blue: 0.35), Color(red: 1.0, green: 0.70, blue: 0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .orange.opacity(0.4), radius: 10, y: 4)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: 680)
            }
        }
    }

    private func instructionRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 46, height: 46)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.75))
            }
            Spacer()
        }
        .padding(14)
        .background(Color.black.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}
