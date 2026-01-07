//
//  AchievementGalleryView.swift
//  Eco Hero
//
//  Displays all achievements in a badge gallery format with progress indicators.
//
//  Created by Rishabh Bansal on 11/15/25.
//

import SwiftUI
import SwiftData

struct AchievementGalleryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AuthenticationManager.self) private var authManager
    @Query private var achievements: [Achievement]

    @State private var selectedTier: AchievementTier? = nil
    @State private var selectedAchievement: Achievement? = nil

    private var userAchievements: [Achievement] {
        achievements.filter { $0.userID == authManager.currentUserID }
    }

    private var filteredAchievements: [Achievement] {
        if let tier = selectedTier {
            return userAchievements.filter { $0.tier == tier }
        }
        return userAchievements
    }

    private var unlockedCount: Int {
        userAchievements.filter { $0.isUnlocked }.count
    }

    private var totalCount: Int {
        userAchievements.count
    }

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header stats
                headerSection

                // Tier filter
                tierFilterSection

                // Achievement grid
                achievementGrid
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color.purple.opacity(0.2), Color.black]
                    : [Color.purple.opacity(0.1), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Achievements")
        .sheet(item: $selectedAchievement) { achievement in
            AchievementDetailSheet(achievement: achievement)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.primary.opacity(0.1), lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: totalCount > 0 ? CGFloat(unlockedCount) / CGFloat(totalCount) : 0)
                    .stroke(
                        AngularGradient(
                            colors: [.purple, .pink, .purple],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(unlockedCount)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    Text("of \(totalCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Achievements Unlocked")
                .font(.headline)

            // Tier breakdown
            HStack(spacing: 20) {
                tierStatBadge(tier: .bronze)
                tierStatBadge(tier: .silver)
                tierStatBadge(tier: .gold)
                tierStatBadge(tier: .platinum)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func tierStatBadge(tier: AchievementTier) -> some View {
        let count = userAchievements.filter { $0.tier == tier && $0.isUnlocked }.count
        let total = userAchievements.filter { $0.tier == tier }.count

        return VStack(spacing: 4) {
            Image(systemName: tierIcon(tier))
                .font(.title3)
                .foregroundStyle(tierColor(tier))
            Text("\(count)/\(total)")
                .font(.caption.bold())
        }
    }

    private var tierFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                filterChip(title: "All", tier: nil)
                filterChip(title: "Bronze", tier: .bronze)
                filterChip(title: "Silver", tier: .silver)
                filterChip(title: "Gold", tier: .gold)
                filterChip(title: "Platinum", tier: .platinum)
            }
            .padding(.horizontal, 4)
        }
    }

    private func filterChip(title: String, tier: AchievementTier?) -> some View {
        let isSelected = selectedTier == tier

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTier = tier
            }
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? (tier.map { tierColor($0) } ?? Color.purple) : Color(.tertiarySystemBackground))
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }

    private var achievementGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(filteredAchievements.sorted(by: { $0.isUnlocked && !$1.isUnlocked })) { achievement in
                AchievementBadgeTile(achievement: achievement)
                    .onTapGesture {
                        selectedAchievement = achievement
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
            }
        }
    }

    // MARK: - Helper Functions

    private func tierIcon(_ tier: AchievementTier) -> String {
        switch tier {
        case .bronze: return "medal.fill"
        case .silver: return "medal.fill"
        case .gold: return "medal.fill"
        case .platinum: return "crown.fill"
        }
    }

    private func tierColor(_ tier: AchievementTier) -> Color {
        switch tier {
        case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.8)
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .platinum: return Color(red: 0.9, green: 0.4, blue: 0.9)
        }
    }
}

// MARK: - Achievement Badge Tile

struct AchievementBadgeTile: View {
    let achievement: Achievement
    @Environment(\.colorScheme) private var colorScheme
    @State private var isAnimating = false

    private var tierColor: Color {
        switch achievement.tier {
        case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.8)
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .platinum: return Color(red: 0.9, green: 0.4, blue: 0.9)
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background glow for unlocked
                if achievement.isUnlocked {
                    Circle()
                        .fill(tierColor.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .blur(radius: 12)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                }

                // Badge ring
                Circle()
                    .stroke(
                        achievement.isUnlocked
                            ? LinearGradient(colors: [tierColor, tierColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 3
                    )
                    .frame(width: 70, height: 70)

                // Progress ring (for locked)
                if !achievement.isUnlocked && achievement.progressRequired > 0 {
                    Circle()
                        .trim(from: 0, to: CGFloat(achievement.progressCurrent / achievement.progressRequired))
                        .stroke(tierColor.opacity(0.5), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))
                }

                // Inner fill
                Circle()
                    .fill(achievement.isUnlocked ? tierColor.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)

                // Icon
                Image(systemName: achievement.iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(achievement.isUnlocked ? tierColor : Color.gray)
                    .symbolEffect(.bounce, value: isAnimating && achievement.isUnlocked)
            }

            // Title
            Text(achievement.title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(achievement.isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 30)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .opacity(achievement.isUnlocked ? 1 : 0.6)
        .onAppear {
            if achievement.isUnlocked {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
        }
    }
}

// MARK: - Achievement Detail Sheet

struct AchievementDetailSheet: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showSparkles = false

    private var tierColor: Color {
        switch achievement.tier {
        case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.8)
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .platinum: return Color(red: 0.9, green: 0.4, blue: 0.9)
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            // Badge display
            ZStack {
                if achievement.isUnlocked {
                    Circle()
                        .fill(tierColor.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)

                    if showSparkles {
                        SparkleParticleView(colors: [tierColor, tierColor.opacity(0.7), .white])
                            .frame(width: 160, height: 160)
                    }
                }

                Circle()
                    .stroke(
                        achievement.isUnlocked
                            ? LinearGradient(colors: [tierColor, tierColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 4
                    )
                    .frame(width: 110, height: 110)

                Circle()
                    .fill(achievement.isUnlocked ? tierColor.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 96, height: 96)

                Image(systemName: achievement.iconName)
                    .font(.system(size: 40))
                    .foregroundStyle(achievement.isUnlocked ? tierColor : Color.gray)
            }

            // Info
            VStack(spacing: 8) {
                Text(achievement.title)
                    .font(.title2.bold())

                Text(achievement.tier.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(tierColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(tierColor.opacity(0.15), in: Capsule())

                Text(achievement.badgeDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            // Progress or unlock date
            if achievement.isUnlocked {
                if let date = achievement.unlockedDate {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text("Unlocked \(date.formatted(date: .abbreviated, time: .omitted))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    ProgressView(value: achievement.progressCurrent, total: achievement.progressRequired)
                        .tint(tierColor)
                        .frame(width: 200)

                    Text("\(Int(achievement.progressCurrent)) / \(Int(achievement.progressRequired))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.top, 32)
        .onAppear {
            if achievement.isUnlocked {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showSparkles = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AchievementGalleryView()
            .environment(AuthenticationManager())
            .modelContainer(for: Achievement.self, inMemory: true)
    }
}
