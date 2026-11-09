import SwiftUI

/// Screen C: Animated 3 -> 2 -> 1 -> GO! launch sequence.
struct StarCollectorCountdownView: View {

    let count: Int

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            StarCollectorSpaceBackgroundView()

            VStack(spacing: 24) {
                Text("GET READY!")
                    .font(.system(size: 20, weight: .bold))
                    .tracking(4)
                    .foregroundStyle(.cyan)

                ZStack {
                    // Pulsing Glow Aura behind number
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.cyan.opacity(0.4), Color.purple.opacity(0.0)],
                                center: .center,
                                startRadius: 20,
                                endRadius: 130
                            )
                        )
                        .frame(width: 260, height: 260)

                    if count > 0 {
                        Text("\(count)")
                            .font(.system(size: 130, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color(red: 0.95, green: 0.85, blue: 0.4)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .orange.opacity(0.8), radius: 20)
                    } else {
                        VStack(spacing: 6) {
                            Text("GO!")
                                .font(.system(size: 95, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .cyan],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .cyan.opacity(0.9), radius: 20)

                            Text("REACH FOR BLUE STARS!")
                                .font(.system(size: 15, weight: .heavy))
                                .tracking(2)
                                .foregroundStyle(.yellow)
                        }
                    }
                }
                .scaleEffect(scale)
                .opacity(opacity)

                StarCollectorAstronautView(emotion: count == 0 ? .celebrating : .idle, size: 100)
                    .padding(.top, 20)
            }
        }
        .onChange(of: count) { _, _ in
            triggerNumberAnimation()
        }
        .onAppear {
            triggerNumberAnimation()
        }
    }

    private func triggerNumberAnimation() {
        scale = 0.4
        opacity = 0.0
        withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
            scale = 1.0
            opacity = 1.0
        }
    }
}
