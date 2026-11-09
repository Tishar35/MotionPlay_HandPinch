import Foundation
import CoreGraphics
import Combine

/// Central coordinator for the Star Collector game loop, collision events,
/// scoring rules, and timer progression.
final class StarCollectorGameManager: ObservableObject {

    @Published var stats = StarCollectorGameStats()
    @Published var stars: [StarCollectorStar] = []
    @Published var recentCollectedStarPosition: CGPoint?
    @Published var distractorWarningActive = false
    @Published var astronautEmotion: AstronautEmotion = .idle

    enum AstronautEmotion {
        case idle
        case celebrating
        case warning
    }

    private let spawner = StarCollectorStarSpawner()
    private let collisionDetector = StarCollectorCollisionDetector()
    private let audio = StarCollectorAudioService.shared

    private var timerSubscription: AnyCancellable?
    private var secondAccumulator: Double = 0.0
    private var isGameCompleted = false

    var onGameCompleted: ((StarCollectorGameStats) -> Void)?

    init() {
        reset()
    }

    /// Resets all variables to their initial state.
    func reset() {
        stats = StarCollectorGameStats()
        stars = []
        recentCollectedStarPosition = nil
        distractorWarningActive = false
        astronautEmotion = .idle
        isGameCompleted = false
        secondAccumulator = 0.0
        collisionDetector.reset()
    }

    /// Starts an active gameplay session with initial targets.
    func startSession() {
        reset()
        populateInitialStars()
    }

    /// Populates the initial wave of stars.
    private func populateInitialStars() {
        stars.removeAll()
        for _ in 0..<StarCollectorConfiguration.minSimultaneousStars {
            var newStar = spawner.spawnStar(existingStars: stars, collectedCount: stats.blueStarsCollected)
            newStar.scale = 1.0
            newStar.opacity = 1.0
            stars.append(newStar)
        }
    }

    /// Called at ~60 Hz (e.g., from `TimelineView`) to advance game physics and timer.
    func tick(deltaTime: Double) {
        guard !isGameCompleted else { return }

        // Update timer
        secondAccumulator += deltaTime
        if secondAccumulator >= 1.0 {
            secondAccumulator -= 1.0
            stats.timeRemaining = max(0, stats.timeRemaining - 1.0)
            if stats.timeRemaining <= 0 {
                finishGame()
                return
            }
        }

        // Update star physics & drift
        spawner.updatePhysics(stars: &stars, deltaTime: deltaTime)

        // Ensure minimum stars on screen if goal is not yet reached
        let activeBlue = stars.filter { $0.type == .collectibleBlue && !$0.isCollected }.count
        let remainingNeeded = stats.targetBlueStars - stats.blueStarsCollected
        let activeTotal = stars.filter { !$0.isCollected }.count

        if activeTotal < StarCollectorConfiguration.maxSimultaneousStars && activeBlue < remainingNeeded {
            var newStar = spawner.spawnStar(existingStars: stars, collectedCount: stats.blueStarsCollected)
            newStar.scale = 1.0
            newStar.opacity = 1.0
            stars.append(newStar)
        }
    }

    /// Evaluates hand pointer position against active stars.
    func processPointer(at point: CGPoint?, areaSize: CGSize) {
        guard !isGameCompleted, let point else { return }

        if let collision = collisionDetector.detectCollision(
            pointer: point,
            stars: stars,
            areaSize: areaSize
        ) {
            let star = collision.star
            let isNewHit = collision.isNewHit

            if star.type == .collectibleBlue {
                if isNewHit && !star.isCollected {
                    collectBlueStar(star)
                }
            } else if star.type == .distractorRed {
                if isNewHit {
                    handleDistractorContact(star)
                }
            }
        }
    }

    /// Handles successful collection of a blue star.
    private func collectBlueStar(_ star: StarCollectorStar) {
        guard let index = stars.firstIndex(where: { $0.id == star.id }), !stars[index].isCollected else {
            return
        }

        // Mark as collected immediately to prevent double scoring
        stars[index].isCollected = true
        stars[index].scale = 1.4
        stars[index].opacity = 0.0

        // Update stats
        stats.blueStarsCollected += 1
        stats.score += star.type.basePoints
        stats.comboStreak += 1
        stats.maxComboStreak = max(stats.maxComboStreak, stats.comboStreak)

        // Visual & audio feedback
        recentCollectedStarPosition = star.position
        astronautEmotion = .celebrating
        audio.playStarCollected()

        // Reset astronaut emotion after short burst
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            if self?.astronautEmotion == .celebrating {
                self?.astronautEmotion = .idle
            }
        }

        // Remove star after animation completes
        let collectedId = star.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.stars.removeAll(where: { $0.id == collectedId })
        }

        // Check victory condition
        if stats.blueStarsCollected >= stats.targetBlueStars {
            finishGame()
        }
    }

    /// Handles contact with a red distractor star.
    private func handleDistractorContact(_ star: StarCollectorStar) {
        guard let index = stars.firstIndex(where: { $0.id == star.id }) else { return }

        // Never increases score; resets combo streak
        stats.distractorTouches += 1
        stats.comboStreak = 0

        // Warning animation on distractor
        stars[index].isWarning = true
        distractorWarningActive = true
        astronautEmotion = .warning
        audio.playDistractorWarning()

        // Remove warning state shortly after
        let starId = star.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            if let idx = self.stars.firstIndex(where: { $0.id == starId }) {
                self.stars[idx].isWarning = false
            }
            self.distractorWarningActive = false
            if self.astronautEmotion == .warning {
                self.astronautEmotion = .idle
            }
        }
    }

    /// Concludes the game session and delivers final statistics.
    private func finishGame() {
        guard !isGameCompleted else { return }
        isGameCompleted = true

        audio.playVictory()
        onGameCompleted?(stats)
    }
}
