import Foundation

/// Defines the primary UI phases / screens for Star Collector.
enum StarCollectorPhase: Equatable {
    case intro         // Screen A: Activity Introduction
    case setup         // Screen B: Input Setup (Demo vs Camera)
    case countdown     // Screen C: 3-2-1-GO
    case playing       // Screen D: Floating Space Gameplay
    case paused        // Screen E: Pause Screen
    case completed     // Screen F: Completion Screen
}

/// The tracking input mechanism selected by the user.
enum StarCollectorTrackingMode: String, CaseIterable, Identifiable {
    case demo = "Demo Mode (Touch / Drag)"
    case camera = "Camera Tracking (Hand Reach)"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .demo: return "hand.point.up.fill"
        case .camera: return "video.fill"
        }
    }

    var explanation: String {
        switch self {
        case .demo:
            return "Touch, drag, or click to move the astronaut glove and collect stars. Works everywhere without a camera."
        case .camera:
            return "Stand back and reach with your hand in front of the iPad camera to catch stars in space!"
        }
    }
}

/// Dynamic metrics and progress for an active game session.
struct StarCollectorGameStats: Equatable {
    var blueStarsCollected: Int = 0
    var targetBlueStars: Int = 8
    var distractorTouches: Int = 0
    var timeRemaining: Double = 60.0
    var totalDuration: Double = 60.0
    var score: Int = 0
    var comboStreak: Int = 0
    var maxComboStreak: Int = 0

    /// Returns the progress towards the blue stars goal (0.0 to 1.0).
    var progressRatio: Double {
        guard targetBlueStars > 0 else { return 0 }
        return min(1.0, Double(blueStarsCollected) / Double(targetBlueStars))
    }

    /// Calculates earned Fizee Stars (1 to 3 stars) emphasizing effort and participation.
    var fizeeStarsEarned: Int {
        if blueStarsCollected >= targetBlueStars {
            // Full collection
            return distractorTouches <= 2 ? 3 : 2
        } else if blueStarsCollected >= 4 {
            return 2
        } else {
            return 1 // Always at least 1 star to celebrate effort!
        }
    }

    var timeTakenSeconds: Int {
        max(1, Int(totalDuration - timeRemaining))
    }

    var timeTakenFormatted: String {
        let seconds = timeTakenSeconds
        if seconds < 60 {
            return "\(seconds)s"
        } else {
            let m = seconds / 60
            let s = seconds % 60
            return "\(m)m \(s)s"
        }
    }

    var accuracyPercentage: Int {
        let totalInteractions = blueStarsCollected + distractorTouches
        guard totalInteractions > 0 else { return 100 }
        return Int((Double(blueStarsCollected) / Double(totalInteractions)) * 100)
    }
}
