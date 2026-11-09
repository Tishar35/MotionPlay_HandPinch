import SwiftUI

/// Defines the nature of a star in the Star Collector game.
enum StarType: Equatable {
    case collectibleBlue
    case distractorRed

    var isCollectible: Bool {
        self == .collectibleBlue
    }

    var basePoints: Int {
        switch self {
        case .collectibleBlue: return 10
        case .distractorRed: return 0
        }
    }

    var label: String {
        switch self {
        case .collectibleBlue: return "Blue Star"
        case .distractorRed: return "Red Distractor"
        }
    }
}

/// Represents a single floating star entity in space.
struct StarCollectorStar: Identifiable, Equatable {
    let id: UUID
    let type: StarType
    
    /// Normalized coordinates (0.0 ... 1.0) within the playable space bounds.
    var position: CGPoint
    
    /// Gentle floating drift vector.
    var velocity: CGVector
    
    /// Base size in points (e.g. 74 pt for generous child-friendly reaching).
    var size: CGFloat
    
    /// Dynamic display scale (used for spawn-in and collection bursts).
    var scale: CGFloat
    
    /// Opacity (used for fade-in and collection fade-out).
    var opacity: Double
    
    /// Visual rotation angle in degrees for floating drift.
    var rotationAngle: Double
    
    /// Pulse phase for gentle cosmic breathing effect.
    var pulsePhase: Double
    
    /// Whether this star has been collected.
    var isCollected: Bool
    
    /// Temporary warning state (wobble/shake when red distractor is contacted).
    var isWarning: Bool
    
    init(
        id: UUID = UUID(),
        type: StarType,
        position: CGPoint,
        velocity: CGVector = CGVector(dx: Double.random(in: -0.015...0.015), dy: Double.random(in: -0.015...0.015)),
        size: CGFloat = 74,
        scale: CGFloat = 0.1,
        opacity: Double = 0.0,
        rotationAngle: Double = Double.random(in: 0...360),
        pulsePhase: Double = Double.random(in: 0...(2 * .pi)),
        isCollected: Bool = false,
        isWarning: Bool = false
    ) {
        self.id = id
        self.type = type
        self.position = position
        self.velocity = velocity
        self.size = size
        self.scale = scale
        self.opacity = opacity
        self.rotationAngle = rotationAngle
        self.pulsePhase = pulsePhase
        self.isCollected = isCollected
        self.isWarning = isWarning
    }
}
