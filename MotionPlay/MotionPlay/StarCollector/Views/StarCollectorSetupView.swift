import SwiftUI
import AVFoundation

/// Screen B: Tracking mode selection and camera positioning setup.
struct StarCollectorSetupView: View {

    @Binding var selectedMode: StarCollectorTrackingMode
    @ObservedObject var cameraProvider: StarCollectorCameraProvider
    let onProceedToCountdown: () -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            StarCollectorSpaceBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Header
                    HStack {
                        Button(action: onBack) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                Text("Intro")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        }
                        Spacer()
                        Text("STEP 2: INPUT SETUP")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(.cyan)
                    }
                    .padding(.top, 10)

                    VStack(spacing: 8) {
                        Text("Choose How You Play")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Select touch demo or camera body motion tracking.")
                            .font(.system(size: 15))
                            .foregroundStyle(.white.opacity(0.8))
                    }

                    // Mode Selection Cards
                    VStack(spacing: 16) {
                        // Demo Mode Card
                        modeCard(
                            mode: .demo,
                            title: "Demo Mode (Touch & Mouse)",
                            badge: "SIMULATOR READY",
                            badgeColor: .green,
                            description: "Play by dragging or tapping on screen with your finger or mouse. No camera required.",
                            icon: "hand.point.up.left.fill",
                            isSelected: selectedMode == .demo
                        )

                        // Camera Mode Card
                        modeCard(
                            mode: .camera,
                            title: "Camera Motion Tracking",
                            badge: "PHYSICAL IPAD",
                            badgeColor: .blue,
                            description: "Stand back and reach with your real hands in front of the front-facing camera to grab stars!",
                            icon: "video.badge.waveform.fill",
                            isSelected: selectedMode == .camera
                        )
                    }

                    // Camera Live Preview & Permission Box (when Camera mode is active)
                    if selectedMode == .camera {
                        cameraSetupBox
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

                    // Ready to Launch Action Button
                    Button(action: {
                        if selectedMode == .camera && cameraProvider.authorizationStatus != .authorized {
                            cameraProvider.startTracking()
                        } else {
                            onProceedToCountdown()
                        }
                    }) {
                        HStack(spacing: 10) {
                            Text("Ready to Play")
                                .font(.system(size: 19, weight: .bold, design: .rounded))
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 22))
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.95, green: 0.85, blue: 0.35), Color(red: 1.0, green: 0.70, blue: 0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .orange.opacity(0.4), radius: 10, y: 4)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: 680)
            }
        }
        .animation(.spring(response: 0.35), value: selectedMode)
        .onAppear {
            if selectedMode == .camera {
                cameraProvider.startTracking()
            }
        }
    }

    private func modeCard(
        mode: StarCollectorTrackingMode,
        title: String,
        badge: String,
        badgeColor: Color,
        description: String,
        icon: String,
        isSelected: Bool
    ) -> some View {
        Button {
            selectedMode = mode
            if mode == .camera {
                cameraProvider.startTracking()
            } else {
                cameraProvider.stopTracking()
            }
        } label: {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.cyan.opacity(0.25) : Color.white.opacity(0.08))
                        .frame(width: 54, height: 54)
                    Image(systemName: icon)
                        .font(.system(size: 26))
                        .foregroundStyle(isSelected ? .cyan : .white)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(title)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Spacer()

                        Text(badge)
                            .font(.system(size: 10, weight: .heavy))
                            .tracking(1)
                            .foregroundStyle(badgeColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(badgeColor.opacity(0.15))
                            .clipShape(Capsule())
                    }

                    Text(description)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(isSelected ? Color.white.opacity(0.15) : Color.black.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(isSelected ? Color.cyan : Color.white.opacity(0.12), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var cameraSetupBox: some View {
        VStack(spacing: 16) {
            HStack {
                Label("CAMERA PREVIEW", systemImage: "video.fill")
                    .font(.caption.bold())
                    .tracking(1)
                    .foregroundStyle(.cyan)
                Spacer()
                Text(cameraProvider.isTrackingActive ? "LIVE" : "STARTING")
                    .font(.caption2.bold())
                    .foregroundStyle(cameraProvider.isTrackingActive ? .green : .orange)
            }

            // Live Camera Preview
            ZStack {
                CameraPreview(session: cameraProvider.session)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
                    )

                if let err = cameraProvider.cameraError {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title)
                            .foregroundStyle(.yellow)
                        Text(err)
                            .font(.system(size: 13, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                        Button("Switch to Demo Mode") {
                            selectedMode = .demo
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.yellow)
                        .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }

            // Positioning Advice
            HStack(spacing: 12) {
                Image(systemName: "figure.walk")
                    .font(.title2)
                    .foregroundStyle(.cyan)
                Text("Position your iPad on a table. Step back 1.5 – 2 meters so your hands can comfortably reach all sides of the screen.")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(14)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}
