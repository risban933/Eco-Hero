//
//  AchievementUnlockOverlay.swift
//  Eco Hero
//
//  Full-screen celebration overlay shown when an achievement is unlocked.
//
//  Created by Rishabh Bansal on 11/15/25.
//

import SwiftUI

struct AchievementUnlockOverlay: View {
    let achievement: Achievement
    let onDismiss: () -> Void

    @State private var showBadge = false
    @State private var showText = false
    @State private var showConfetti = false
    @State private var ringScale: CGFloat = 0.3
    @State private var iconScale: CGFloat = 0.1
    @State private var backgroundOpacity: Double = 0

    private var tierColor: Color {
        switch achievement.tier {
        case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.8)
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .platinum: return Color(red: 0.9, green: 0.4, blue: 0.9)
        }
    }

    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissOverlay()
                }

            VStack(spacing: 24) {
                Spacer()

                // Confetti
                if showConfetti {
                    ConfettiView(colors: [tierColor, tierColor.opacity(0.7), .white, .yellow])
                        .frame(height: 300)
                }

                // Achievement badge
                ZStack {
                    // Glow
                    if showBadge {
                        Circle()
                            .fill(tierColor.opacity(0.4))
                            .frame(width: 200, height: 200)
                            .blur(radius: 40)
                    }

                    // Outer ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [tierColor, tierColor.opacity(0.5), tierColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 6
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(ringScale)

                    // Inner fill
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [tierColor.opacity(0.3), tierColor.opacity(0.1)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(ringScale)

                    // Icon
                    Image(systemName: achievement.iconName)
                        .font(.system(size: 56, weight: .medium))
                        .foregroundStyle(tierColor)
                        .scaleEffect(iconScale)
                        .shadow(color: tierColor.opacity(0.5), radius: 10)
                }
                .frame(height: 200)

                // Text content
                if showText {
                    VStack(spacing: 12) {
                        Text("Achievement Unlocked!")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.8))

                        Text(achievement.title)
                            .font(.title.bold())
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)

                        Text(achievement.badgeDescription)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        // Tier badge
                        Text(achievement.tier.rawValue)
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(tierColor.opacity(0.8), in: Capsule())
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()

                // Dismiss hint
                if showText {
                    Text("Tap anywhere to continue")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.bottom, 40)
                        .transition(.opacity)
                }
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // Background fade in
        withAnimation(.easeOut(duration: 0.3)) {
            backgroundOpacity = 0.85
        }

        // Badge scale in with bounce
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
            showBadge = true
            ringScale = 1.0
        }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.2)) {
            iconScale = 1.0
        }

        // Confetti burst
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                showConfetti = true
            }
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }

        // Text fade in
        withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
            showText = true
        }

        // Auto-dismiss after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            dismissOverlay()
        }
    }

    private func dismissOverlay() {
        withAnimation(.easeOut(duration: 0.3)) {
            backgroundOpacity = 0
            showBadge = false
            showText = false
            showConfetti = false
            ringScale = 0.3
            iconScale = 0.1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    let colors: [Color]

    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                        .rotationEffect(.degrees(particle.rotation))
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
            }
        }
    }

    private func createParticles(in size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2

        for i in 0..<50 {
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = Double.random(in: 50...200)
            let targetX = centerX + CGFloat(cos(angle) * distance)
            let targetY = centerY + CGFloat(sin(angle) * distance) - 100

            var particle = ConfettiParticle(
                id: i,
                color: colors.randomElement() ?? .white,
                size: CGFloat.random(in: 4...10),
                position: CGPoint(x: centerX, y: centerY),
                opacity: 1,
                rotation: 0
            )

            particles.append(particle)

            let index = particles.count - 1

            withAnimation(.easeOut(duration: Double.random(in: 0.8...1.5))) {
                particles[index].position = CGPoint(x: targetX, y: targetY)
                particles[index].rotation = Double.random(in: 180...720)
            }

            withAnimation(.easeIn(duration: 1.5).delay(0.5)) {
                particles[index].opacity = 0
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: Int
    let color: Color
    let size: CGFloat
    var position: CGPoint
    var opacity: Double
    var rotation: Double
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()

        AchievementUnlockOverlay(
            achievement: Achievement(
                badgeID: "test",
                title: "Carbon Crusher",
                description: "Save 100 kg of CO₂",
                tier: .gold,
                iconName: "sun.max.fill",
                progressRequired: 100
            ),
            onDismiss: {}
        )
    }
}
