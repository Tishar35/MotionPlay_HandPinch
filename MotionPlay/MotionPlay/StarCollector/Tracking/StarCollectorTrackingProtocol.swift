import Foundation
import CoreGraphics
import Combine

/// Standardized interface for tracking inputs in Star Collector.
protocol StarCollectorTrackingProvider: AnyObject, ObservableObject {
    /// Normalized coordinates (0.0 ... 1.0) of the user's hand/pointer in the play space.
    var pointerPosition: CGPoint? { get }

    /// Whether tracking is currently active and processing inputs.
    var isTrackingActive: Bool { get }

    /// Whether a person / hand is detected by the input system.
    var isPersonDetected: Bool { get }

    /// Mode identifier for this provider.
    var mode: StarCollectorTrackingMode { get }

    /// Starts capturing/tracking inputs.
    func startTracking()

    /// Stops tracking and releases associated resources.
    func stopTracking()
}
