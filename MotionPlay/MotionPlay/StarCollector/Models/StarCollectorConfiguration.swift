import Foundation
import CoreGraphics

/// Game balance and layout constants for Star Collector.
struct StarCollectorConfiguration {
    /// Objective: number of blue stars needed to win.
    static let targetBlueStars: Int = 8

    /// Total game time in seconds.
    static let gameDurationSeconds: Double = 60.0

    /// Maximum active targets on screen simultaneously.
    static let maxSimultaneousStars: Int = 3

    /// Minimum targets maintained on screen while remaining.
    static let minSimultaneousStars: Int = 2

    /// Generous collision radius in points for child-friendly hand reaching.
    static let collisionRadius: CGFloat = 68.0

    /// Normalised margins (0.0...1.0) so stars float safely away from screen edges and HUD.
    static let safeMarginX: ClosedRange<CGFloat> = 0.12...0.88
    static let safeMarginY: ClosedRange<CGFloat> = 0.20...0.80

    /// Base spawn chance for a red distractor star (scales with progress).
    static let baseDistractorProbability: Double = 0.30

    /// Cooldown in seconds before the same red star can register another contact warning.
    static let redDistractorCooldown: Double = 1.0

    /// Delay in seconds before a replacement star spawns after collection.
    static let starRespawnDelay: Double = 0.8
}
