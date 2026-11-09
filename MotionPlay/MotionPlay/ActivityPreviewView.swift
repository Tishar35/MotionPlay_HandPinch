
import SwiftUI

struct ActivityPreviewView: View {

    @Environment(\.dismiss) private var dismiss

    private let blue = Color(red: 0.22, green: 0.48, blue: 0.95)

    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.97, blue: 0.96)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 26) {

                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ACTIVITY 01")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(blue)

                        Text("Move & Match")
                            .font(.system(size: 34, weight: .bold))

                        Text("Move your body. Find the right fruit. Have fun!")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    }

                    // Activity Illustration
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.88, green: 0.93, blue: 1),
                                        Color(red: 0.94, green: 0.96, blue: 1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        HStack(spacing: 28) {
                            Image(systemName: "figure.run")
                                .font(.system(size: 85))
                                .foregroundStyle(blue)

                            VStack(spacing: 18) {
                                Image(systemName: "apple.logo")
                                    .font(.system(size: 42))
                                    .foregroundStyle(.red)

                                Image(systemName: "carrot.fill")
                                    .font(.system(size: 38))
                                    .foregroundStyle(.orange)

                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(.green)
                            }
                        }
                        .padding(25)
                    }
                    .frame(height: 220)

                    // Objective
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your Mission")
                            .font(.system(size: 22, weight: .bold))

                        Text("Follow the instruction and collect only the matching objects by moving your body.")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Instructions
                    VStack(alignment: .leading, spacing: 18) {
                        Text("How to Play")
                            .font(.system(size: 22, weight: .bold))

                        instructionRow(
                            number: "01",
                            icon: "figure.stand",
                            title: "Stand in front",
                            subtitle: "Position yourself in front of the camera."
                        )

                        instructionRow(
                            number: "02",
                            icon: "hand.point.up.left",
                            title: "Read the instruction",
                            subtitle: "Find out which fruit you need to collect."
                        )

                        instructionRow(
                            number: "03",
                            icon: "figure.run",
                            title: "Move and collect",
                            subtitle: "Move left or right to reach the correct fruit."
                        )
                    }

                    // Activity Details
                    HStack(spacing: 12) {
                        detailCard(
                            icon: "clock",
                            title: "Duration",
                            value: "2–3 min"
                        )

                        detailCard(
                            icon: "chart.bar",
                            title: "Level",
                            value: "Beginner"
                        )

                        detailCard(
                            icon: "figure.mind.and.body",
                            title: "Mode",
                            value: "Movement"
                        )
                    }

               
                    // Start Button
                    NavigationLink {
                        GamePlayView(onReturnHome: { dismiss() })
                    } label: {
                        HStack {
                            Text("Start Activity")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 22)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 19)
                        .background(blue)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(28)
                .frame(maxWidth: 850)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Move & Match")
        .navigationBarTitleDisplayMode(.inline)
    
    }

    private func instructionRow(
        number: String,
        icon: String,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(spacing: 16) {
            Text(number)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(blue)
                .frame(width: 30)

            Image(systemName: icon)
                .font(.system(size: 23))
                .foregroundStyle(blue)
                .frame(width: 48, height: 48)
                .background(blue.opacity(0.09))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
    }

    private func detailCard(
        icon: String,
        title: String,
        value: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(systemName: icon)
                .foregroundStyle(blue)

            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 17))
    }
}


struct GamePlayView: View {

    var onReturnHome: () -> Void = {}

    @State private var round = 1
    @State private var score = 0
    @State private var targetColor: FruitColor = .blue
    @State private var feedback = "Collect the BLUE fruits!"
    @State private var showResults = false
    @State private var collectedFruits = 0
    @State private var attemptCount = 0
    @State private var collectedFruitID: UUID?
    @State private var wrongFruitID: UUID?
    @StateObject private var cameraManager = CameraManager()
    @State private var fruits: [GameFruit] =
        GameFruit.make(for: .blue)

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.97, blue: 0.95)
                .ignoresSafeArea()

            VStack(spacing: 22) {

                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MOTIONPLAY")
                            .font(.caption.bold())
                            .tracking(2)
                            .foregroundStyle(.secondary)

                        Text("Move & Match")
                            .font(.title2.bold())
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("SCORE")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)

                        Text("\(score)")
                            .font(.title2.bold())
                            .foregroundStyle(.blue)
                    }
                }

                // Round Progress
                HStack {
                    Text("ROUND \(round) OF 3")
                        .font(.caption.bold())

                    Spacer()

                    ProgressView(value: Double(round), total: 3)
                        .tint(.green)
                        .frame(width: 130)
                }

                // Live camera and body-tracking status
                HStack(spacing: 14) {
                    CameraPreview(session: cameraManager.session)
                        .frame(width: 150, height: 104)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white, lineWidth: 2))

                    VStack(alignment: .leading, spacing: 7) {
                        Label(cameraManager.isCameraRunning ? "CAMERA LIVE" : "STARTING CAMERA",
                              systemImage: cameraManager.isCameraRunning ? "video.fill" : "video")
                            .font(.caption.bold())
                            .foregroundStyle(cameraManager.isCameraRunning ? .green : .secondary)
                        Text(cameraManager.isPersonDetected
                             ? "Hand detected. Pinch thumb + index finger to collect."
                             : "Show one hand clearly to the camera.")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        if let error = cameraManager.cameraError {
                            Text(error).font(.caption2).foregroundStyle(.red)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(12)
                .background(.white.opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: 20))

                // Game Area
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.85, green: 0.94, blue: 0.87),
                                    Color(red: 0.94, green: 0.96, blue: 0.88)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(spacing: 16) {
                        Text("YOUR MISSION")
                            .font(.caption.bold())
                            .tracking(2)
                            .foregroundStyle(.secondary)

                        Text("Collect the \(targetColor.rawValue.uppercased()) fruits!")
                            .font(.system(size: 27, weight: .bold))
                            .multilineTextAlignment(.center)

                        Text(feedback)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(fruits.indices, id: \.self) { index in
                                fruitButton(at: index)
                            }
                        }
                        .overlay {
                            handCursorOverlay
                        }
                    }
                    .padding(22)
                }

                // Bottom instruction
                HStack(spacing: 10) {
                    Image(systemName: "hand.tap.fill")
                        .foregroundStyle(.blue)

                    Text("Move your hand. Pinch thumb and index finger to collect a fruit.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }
            .padding(25)

        }
        .navigationTitle("Let's Play")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showResults) {
            ResultsView(onDone: onReturnHome, score: score, totalFruits: attemptCount, correctFruits: collectedFruits)
        }
        .onAppear { if DebugConfig.enableCamera { cameraManager.startCamera() } }
        .onDisappear { cameraManager.stopCamera() }
        .onChange(of: cameraManager.pinchEventCount) { _, _ in
            handlePinchSelection()
        }
    }


    private var handCursorOverlay: some View {
        GeometryReader { geometry in
            if let point = cameraManager.handPointer {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.95))
                        .frame(width: 34, height: 34)
                        .overlay {
                            Circle().stroke(.blue, lineWidth: 3)
                        }
                        .shadow(color: .black.opacity(0.2), radius: 8)

                    Image(systemName: cameraManager.isPinching
                          ? "hand.pinch.fill"
                          : "hand.point.up.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.blue)
                }
                .scaleEffect(cameraManager.isPinching ? 0.82 : 1)
                .position(
                    x: point.x * geometry.size.width,
                    y: point.y * geometry.size.height
                )
                .allowsHitTesting(false)
            }
        }
    }

    @ViewBuilder
    private func fruitButton(at index: Int) -> some View {
        let fruit = fruits[index]
        Button {
            collect(fruit)
        } label: {
            VStack(spacing: 8) {
                Text(fruit.emoji)
                    .font(.system(size: 42))
                Text(fruit.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 105)
            .background(
                wrongFruitID == fruit.id
                    ? Color.red.opacity(0.12)
                    : Color.white.opacity(0.9)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        wrongFruitID == fruit.id
                            ? Color.red
                            : Color.clear,
                        lineWidth: 2
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .scaleEffect(collectedFruitID == fruit.id ? 0.65 : 1)
            .opacity(collectedFruitID == fruit.id ? 0 : 1)
            .modifier(
                ShakeEffect(
                    animatableData: wrongFruitID == fruit.id ? 1 : 0
                )
            )
            .animation(.spring(response: 0.3), value: collectedFruitID)
            .animation(.easeInOut(duration: 0.4), value: wrongFruitID)
        }
        .buttonStyle(.plain)
    }

    private func handlePinchSelection() {
        guard let point = cameraManager.handPointer else { return }

        // Map the tracked fingertip into the 3 x 3 fruit grid.
        let column = min(2, max(0, Int(point.x * 3)))
        let row = min(2, max(0, Int(point.y * 3)))
        let index = row * 3 + column

        guard fruits.indices.contains(index) else { return }
        collect(fruits[index])
    }

    private func collect(_ fruit: GameFruit) {
        attemptCount += 1

        guard fruit.color == targetColor else {
            wrongFruitID = fruit.id
            feedback = "Oops! That's not the right fruit. Try another lane."
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if wrongFruitID == fruit.id { wrongFruitID = nil }
            }
            return
        }

        collectedFruitID = fruit.id
        score += 10
        collectedFruits += 1
        feedback = "Great job! +10 points"

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                fruits.removeAll { $0.id == fruit.id }
                collectedFruitID = nil
            }

            if !fruits.contains(where: { $0.color == targetColor }) {
                if round == 3 {
                    showResults = true
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        round += 1
                        targetColor = [.blue, .red, .yellow][round - 1]
                        fruits = GameFruit.make(for: targetColor)
                        feedback = "New round! Find the \(targetColor.rawValue.uppercased()) fruits."
                    }
                }
            }
        }
    }

    private func resetGame() {
        collectedFruits = 0
        attemptCount = 0
        round = 1
        score = 0
        targetColor = .blue
        feedback = "Collect the BLUE fruits!"
        fruits = GameFruit.make(for: .blue)
        collectedFruitID = nil
        wrongFruitID = nil
    }

}
struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = 10 * sin(animatableData * .pi * 6)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

enum FruitColor: String {
    case blue = "Blue"
    case red = "Red"
    case yellow = "Yellow"
    case green = "Green"
    case orange = "Orange"
}

struct GameFruit: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let color: FruitColor

    static func make(for target: FruitColor) -> [GameFruit] {
        let allFruits: [GameFruit] = [
            GameFruit(name: "Blueberry", emoji: "🫐", color: .blue),
            GameFruit(name: "Grapes", emoji: "🍇", color: .blue),
            GameFruit(name: "Plum", emoji: "🫐", color: .blue),
            GameFruit(name: "Strawberry", emoji: "🍓", color: .red),
            GameFruit(name: "Apple", emoji: "🍎", color: .red),
            GameFruit(name: "Cherries", emoji: "🍒", color: .red),
            GameFruit(name: "Banana", emoji: "🍌", color: .yellow),
            GameFruit(name: "Lemon", emoji: "🍋", color: .yellow),
            GameFruit(name: "Pineapple", emoji: "🍍", color: .yellow),
            GameFruit(name: "Pear", emoji: "🍐", color: .green),
            GameFruit(name: "Watermelon", emoji: "🍉", color: .green),
            GameFruit(name: "Orange", emoji: "🍊", color: .orange),
            GameFruit(name: "Mango", emoji: "🥭", color: .orange)
        ]

        let matching = allFruits.filter { $0.color == target }.shuffled()
        let distractors = allFruits.filter { $0.color != target }.shuffled().prefix(6)
        return (Array(matching.prefix(3)) + Array(distractors)).shuffled()
    }
}
