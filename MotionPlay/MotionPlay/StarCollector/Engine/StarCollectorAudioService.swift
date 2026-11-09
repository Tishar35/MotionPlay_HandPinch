import Foundation
import AudioToolbox
import AVFoundation

/// Provides audio-visual audio feedback and chimes for Star Collector.
/// Uses AudioServices to ensure zero external asset dependencies while providing
/// reliable child-friendly auditory feedback.
final class StarCollectorAudioService {
    static let shared = StarCollectorAudioService()

    private init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("StarCollector: Audio session configuration notice: \(error)")
        }
        #endif
    }

    /// Plays a bright chime when a blue star is successfully collected.
    func playStarCollected() {
        // System Sound ID 1057 (PIN keypad / chime) or 1103 (tink)
        AudioServicesPlaySystemSound(1057)
    }

    /// Plays a gentle warning tone when a red distractor is contacted.
    func playDistractorWarning() {
        // System Sound ID 1053 (gentle knock/boing)
        AudioServicesPlaySystemSound(1053)
    }

    /// Plays a short countdown tick.
    func playCountdownTick() {
        AudioServicesPlaySystemSound(1104)
    }

    /// Plays the blastoff sound when the countdown finishes.
    func playBlastoff() {
        AudioServicesPlaySystemSound(1025)
    }

    /// Plays a celebratory fanfare when the mission is completed.
    func playVictory() {
        AudioServicesPlaySystemSound(1026)
    }
}
