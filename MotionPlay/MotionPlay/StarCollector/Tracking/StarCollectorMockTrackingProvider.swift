import Foundation
import CoreGraphics
import Combine

/// Mock tracking provider for Demo Mode.
/// Simulates hand tracking via touch, drag, and mouse inputs for testing and Simulator execution.
final class StarCollectorMockTrackingProvider: StarCollectorTrackingProvider {

    @Published private(set) var pointerPosition: CGPoint?
    @Published private(set) var isTrackingActive: Bool = false
    @Published private(set) var isPersonDetected: Bool = false

    let mode: StarCollectorTrackingMode = .demo

    func startTracking() {
        isTrackingActive = true
        isPersonDetected = true
        // Default to center if not yet touched
        if pointerPosition == nil {
            pointerPosition = CGPoint(x: 0.5, y: 0.5)
        }
    }

    func stopTracking() {
        isTrackingActive = false
        isPersonDetected = false
        pointerPosition = nil
    }

    /// Directly updates the pointer position from touch or drag in normalized (0.0 ... 1.0) space.
    func updateTouch(normalizedPoint: CGPoint) {
        let clampedX = min(1.0, max(0.0, normalizedPoint.x))
        let clampedY = min(1.0, max(0.0, normalizedPoint.y))
        pointerPosition = CGPoint(x: clampedX, y: clampedY)
        isPersonDetected = true
    }

    /// Updates the pointer from screen coordinates and view bounds.
    func updateTouch(screenPoint: CGPoint, viewSize: CGSize) {
        guard viewSize.width > 0, viewSize.height > 0 else { return }
        let normX = screenPoint.x / viewSize.width
        let normY = screenPoint.y / viewSize.height
        updateTouch(normalizedPoint: CGPoint(x: normX, y: normY))
    }
}
