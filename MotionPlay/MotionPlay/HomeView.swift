
import SwiftUI

enum ActivityDestination: Hashable {
    case moveAndMatch
    case starCollector
}

struct HomeView: View {

    @State private var navigationPath: [ActivityDestination] = []

    private let background = Color(
        red: 0.96, green: 0.97, blue: 0.96
    )

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {

                        // MARK: Header
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("MOTIONPLAY")
                                    .font(.system(size: 13, weight: .bold))
                                    .tracking(2)
                                    .foregroundStyle(.secondary)

                                Text("Let's get moving.")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(Color.black)
                            }

                            Spacer()

                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 38))
                                .foregroundStyle(.gray.opacity(0.7))
                        }

                        // MARK: Hero Card
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.12, green: 0.25, blue: 0.22),
                                            Color(red: 0.20, green: 0.39, blue: 0.32)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                            Circle()
                                .fill(.white.opacity(0.07))
                                .frame(width: 260)
                                .offset(x: 390, y: -80)

                            VStack(alignment: .leading, spacing: 18) {
                                Text("YOUR PLAYGROUND")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(2)
                                    .foregroundStyle(.white.opacity(0.7))

                                Text("Move your body.\nTrain your mind.")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundStyle(.white)

                                Text("Fun activities designed to get you moving.")
                                    .font(.system(size: 15))
                                    .foregroundStyle(.white.opacity(0.8))

                                NavigationLink(value: ActivityDestination.moveAndMatch) {
                                    HStack(spacing: 10) {
                                        Text("Start Playing")
                                        Image(systemName: "arrow.right")
                                    }
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 22)
                                    .padding(.vertical, 14)
                                    .background(.white)
                                    .clipShape(Capsule())
                                }
                            }
                            .padding(30)
                        }
                        .frame(height: 290)
                        .clipShape(RoundedRectangle(cornerRadius: 30))

                        // MARK: Activities
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Explore Activities")
                                    .font(.system(size: 23, weight: .bold))

                                Spacer()

                                Text("2 ACTIVITIES")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1)
                                    .foregroundStyle(.secondary)
                            }

                            // Activity 1: Move & Match (Untouched Destination)
                            NavigationLink(value: ActivityDestination.moveAndMatch) {
                                HStack(spacing: 18) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.blue.opacity(0.10))
                                            .frame(width: 76, height: 76)

                                        Image(systemName: "figure.run")
                                            .font(.system(size: 34, weight: .medium))
                                            .foregroundStyle(.blue)
                                    }

                                    VStack(alignment: .leading, spacing: 7) {
                                        Text("Move & Match")
                                            .font(.system(size: 19, weight: .bold))
                                            .foregroundStyle(.primary)

                                        Text("Move, identify and match objects")
                                            .font(.system(size: 13))
                                            .foregroundStyle(.secondary)

                                        Text("BODY MOVEMENT")
                                            .font(.system(size: 10, weight: .bold))
                                            .tracking(1)
                                            .foregroundStyle(.blue)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                }
                                .padding(18)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                            }
                            .buttonStyle(.plain)

                            // Activity 2: Star Collector (New Independent Activity)
                            NavigationLink(value: ActivityDestination.starCollector) {
                                HStack(spacing: 18) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 0.16, green: 0.12, blue: 0.35),
                                                        Color(red: 0.28, green: 0.18, blue: 0.52)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 76, height: 76)

                                        Image(systemName: "star.fill")
                                            .font(.system(size: 32, weight: .medium))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.yellow, .orange],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .shadow(color: .yellow.opacity(0.6), radius: 6)
                                    }

                                    VStack(alignment: .leading, spacing: 7) {
                                        HStack(spacing: 6) {
                                            Text("Star Collector")
                                                .font(.system(size: 19, weight: .bold))
                                                .foregroundStyle(.primary)

                                            Image(systemName: "sparkles")
                                                .font(.system(size: 12))
                                                .foregroundStyle(.orange)
                                        }

                                        Text("Reach and catch lost blue stars in space")
                                            .font(.system(size: 13))
                                            .foregroundStyle(.secondary)

                                        Text("HAND & BODY REACH • UNIVERSE")
                                            .font(.system(size: 10, weight: .bold))
                                            .tracking(1)
                                            .foregroundStyle(Color.purple)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                }
                                .padding(18)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                            }
                            .buttonStyle(.plain)
                        }

                        // MARK: Footer
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.orange)

                            Text("Every move is a step forward.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .padding(30)
                    .frame(maxWidth: 1050)
                    .frame(maxWidth: .infinity)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ActivityDestination.self) { destination in
                switch destination {
                case .moveAndMatch:
                    ActivityPreviewView()
                case .starCollector:
                    StarCollectorCoordinatorView()
                }
            }
        }
    }
}



#Preview {
    HomeView()
}
