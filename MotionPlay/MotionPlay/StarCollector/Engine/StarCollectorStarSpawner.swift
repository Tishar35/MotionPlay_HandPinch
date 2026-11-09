import Foundation
import CoreGraphics

/// Manages the spawning and subtle celestial drifting physics of stars.
final class StarCollectorStarSpawner {

    /// Generates a newly positioned star within child-safe viewport bounds.
    ///
    /// - Parameters:
    ///   - existingStars: Current stars on screen to avoid overlapping spawns.
    ///   - collectedCount: Current number of blue stars collected (for difficulty scaling).
    /// - Returns: A configured `StarCollectorStar`.
    func spawnStar(
        existingStars: [StarCollectorStar],
        collectedCount: Int
    ) -> StarCollectorStar {
        // Red distractors are gradually introduced:
        // Round 1-2: 0% red
        // Round 3-5: 25% red
        // Round 6+: 35% red
        let redProbability: Double
        if collectedCount < 2 {
            redProbability = 0.0
        } else if collectedCount < 5 {
            redProbability = 0.25
        } else {
            redProbability = StarCollectorConfiguration.baseDistractorProbability
        }

        // Avoid having more than 1 red distractor simultaneously
        let hasRedAlready = existingStars.contains(where: { $0.type == .distractorRed && !$0.isCollected })
        let starType: StarType = (!hasRedAlready && Double.random(in: 0...1) < redProbability)
            ? .distractorRed
            : .collectibleBlue

        // Find a spawn position with minimum distance separation from existing stars
        var bestPosition = CGPoint(
            x: CGFloat.random(in: StarCollectorConfiguration.safeMarginX),
            y: CGFloat.random(in: StarCollectorConfiguration.safeMarginY)
        )

        for _ in 0..<10 {
            let candidate = CGPoint(
                x: CGFloat.random(in: StarCollectorConfiguration.safeMarginX),
                y: CGFloat.random(in: StarCollectorConfiguration.safeMarginY)
            )

            let isFarEnough = existingStars.allSatisfy { other in
                let dx = candidate.x - other.position.x
                let dy = candidate.y - other.position.y
                return hypot(dx, dy) > 0.22
            }

            if isFarEnough {
                bestPosition = candidate
                break
            }
        }

        // Slight drift velocity
        let speed: CGFloat = 0.012
        let angle = Double.random(in: 0...(2 * .pi))
        let velocity = CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)

        return StarCollectorStar(
            type: starType,
            position: bestPosition,
            velocity: velocity,
            size: starType == .collectibleBlue ? 76 : 68,
            scale: 0.1,
            opacity: 0.0
        )
    }

    /// Advances the cosmic floating drift of all active stars, bouncing smoothly within bounds.
    func updatePhysics(stars: inout [StarCollectorStar], deltaTime: Double) {
        let minX = StarCollectorConfiguration.safeMarginX.lowerBound
        let maxX = StarCollectorConfiguration.safeMarginX.upperBound
        let minY = StarCollectorConfiguration.safeMarginY.lowerBound
        let maxY = StarCollectorConfiguration.safeMarginY.upperBound

        for i in stars.indices {
            guard !stars[i].isCollected else { continue }

            // Drift movement
            stars[i].position.x += stars[i].velocity.dx * CGFloat(deltaTime)
            stars[i].position.y += stars[i].velocity.dy * CGFloat(deltaTime)

            // Gentle wall bounce
            if stars[i].position.x < minX {
                stars[i].position.x = minX
                stars[i].velocity.dx = abs(stars[i].velocity.dx)
            } else if stars[i].position.x > maxX {
                stars[i].position.x = maxX
                stars[i].velocity.dx = -abs(stars[i].velocity.dx)
            }

            if stars[i].position.y < minY {
                stars[i].position.y = minY
                stars[i].velocity.dy = abs(stars[i].velocity.dy)
            } else if stars[i].position.y > maxY {
                stars[i].position.y = maxY
                stars[i].velocity.dy = -abs(stars[i].velocity.dy)
            }

            // Subtle rotation drift
            stars[i].rotationAngle = (stars[i].rotationAngle + (10 * deltaTime)).truncatingRemainder(dividingBy: 360)
            stars[i].pulsePhase = (stars[i].pulsePhase + (2.5 * deltaTime)).truncatingRemainder(dividingBy: 2 * .pi)
        }
    }
}
