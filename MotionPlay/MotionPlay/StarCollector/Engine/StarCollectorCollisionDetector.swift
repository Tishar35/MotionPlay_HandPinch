import Foundation
import CoreGraphics

/// Handles detection of hand pointer contact with floating celestial targets.
final class StarCollectorCollisionDetector {

    /// Set of star IDs currently in collision contact to prevent duplicate hits.
    private var activeContacts: Set<UUID> = []
    
    /// Tracks cooldown timestamps for red distractors.
    private var distractorCooldowns: [UUID: Date] = [:]

    /// Checks if a hand pointer collides with any visible active star.
    ///
    /// - Parameters:
    ///   - pointer: Normalized pointer location (0.0...1.0) in game area coordinates.
    ///   - stars: Currently floating stars.
    ///   - areaSize: Current pixel/point dimensions of the gameplay canvas.
    ///   - radius: Collision tolerance radius in screen points.
    /// - Returns: The colliding star and whether it is a fresh interaction.
    func detectCollision(
        pointer: CGPoint?,
        stars: [StarCollectorStar],
        areaSize: CGSize,
        radius: CGFloat = StarCollectorConfiguration.collisionRadius
    ) -> (star: StarCollectorStar, isNewHit: Bool)? {
        guard let pointer, areaSize.width > 0, areaSize.height > 0 else {
            activeContacts.removeAll()
            return nil
        }

        let pointerScreen = CGPoint(
            x: pointer.x * areaSize.width,
            y: pointer.y * areaSize.height
        )

        for star in stars {
            guard !star.isCollected else { continue }

            let starScreen = CGPoint(
                x: star.position.x * areaSize.width,
                y: star.position.y * areaSize.height
            )

            let dx = pointerScreen.x - starScreen.x
            let dy = pointerScreen.y - starScreen.y
            let distance = hypot(dx, dy)

            // Hitbox includes star radius + hand reach tolerance
            let hitThreshold = (star.size / 2.0) + radius

            if distance <= hitThreshold {
                if star.type == .distractorRed {
                    // Check cooldown for red distractor
                    let now = Date()
                    if let lastHit = distractorCooldowns[star.id], now.timeIntervalSince(lastHit) < StarCollectorConfiguration.redDistractorCooldown {
                        return (star, false)
                    }
                    distractorCooldowns[star.id] = now
                    return (star, true)
                } else {
                    // Blue collectible
                    if !activeContacts.contains(star.id) {
                        activeContacts.insert(star.id)
                        return (star, true)
                    }
                    return (star, false)
                }
            }
        }

        // Pointer moved away from stars
        activeContacts.removeAll()
        return nil
    }

    /// Resets contact caches when game restarts or stars clear.
    func reset() {
        activeContacts.removeAll()
        distractorCooldowns.removeAll()
    }
}
