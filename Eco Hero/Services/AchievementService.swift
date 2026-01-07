//
//  AchievementService.swift
//  Eco Hero
//
//  Manages achievement tracking, unlocking, and persistence.
//
//  Created by Rishabh Bansal on 11/15/25.
//

import Foundation
import SwiftData
import Observation

@Observable
final class AchievementService {
    private var modelContext: ModelContext?
    private var notificationService: NotificationService?

    /// Recently unlocked achievements (for showing unlock overlay)
    private(set) var recentlyUnlocked: [Achievement] = []

    /// Whether an unlock overlay should be shown
    var shouldShowUnlockOverlay: Bool {
        !recentlyUnlocked.isEmpty
    }

    init() {}

    // MARK: - Setup

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func setNotificationService(_ service: NotificationService) {
        self.notificationService = service
    }

    // MARK: - Achievement Initialization

    /// Initialize achievements for a user (creates achievement records if they don't exist)
    func initializeAchievements(for userID: String) {
        guard let context = modelContext else {
            print("⚠️ AchievementService: No model context set")
            return
        }

        // Fetch existing achievements for user
        let descriptor = FetchDescriptor<Achievement>(
            predicate: #Predicate<Achievement> { achievement in
                achievement.userID == userID
            }
        )

        do {
            let existingAchievements = try context.fetch(descriptor)
            let existingBadgeIDs = Set(existingAchievements.map { $0.badgeID })

            // Create missing achievements
            for definition in AchievementCatalog.allDefinitions {
                if !existingBadgeIDs.contains(definition.badgeID) {
                    let achievement = Achievement(
                        badgeID: definition.badgeID,
                        title: definition.title,
                        description: definition.description,
                        tier: definition.tier,
                        iconName: definition.iconName,
                        category: definition.category,
                        progressRequired: definition.progressRequired,
                        userID: userID
                    )
                    context.insert(achievement)
                }
            }

            try context.save()
            print("✅ AchievementService: Initialized achievements for user \(userID)")
        } catch {
            print("❌ AchievementService: Failed to initialize achievements: \(error.localizedDescription)")
        }
    }

    // MARK: - Progress Updates

    /// Update progress for a specific achievement
    func updateProgress(badgeID: String, userID: String, amount: Double) {
        guard let achievement = getAchievement(badgeID: badgeID, userID: userID) else { return }
        guard !achievement.isUnlocked else { return }

        let wasUnlocked = achievement.isUnlocked
        achievement.updateProgress(by: amount)

        if achievement.isUnlocked && !wasUnlocked {
            handleUnlock(achievement)
        }

        saveContext()
    }

    /// Set absolute progress for an achievement (useful for streaks, levels)
    func setProgress(badgeID: String, userID: String, value: Double) {
        guard let achievement = getAchievement(badgeID: badgeID, userID: userID) else { return }
        guard !achievement.isUnlocked else { return }

        let wasUnlocked = achievement.isUnlocked
        achievement.progressCurrent = value

        if achievement.progressCurrent >= achievement.progressRequired && !wasUnlocked {
            achievement.unlock()
            handleUnlock(achievement)
        }

        saveContext()
    }

    // MARK: - Batch Updates (for activity logging)

    /// Check and update achievements after an activity is logged
    func checkActivityAchievements(userID: String, profile: UserProfile) {
        // Activity count achievements
        let activityCount = Double(profile.totalActivitiesLogged)
        setProgress(badgeID: "first_steps", userID: userID, value: min(activityCount, 1))
        setProgress(badgeID: "getting_started", userID: userID, value: activityCount)
        setProgress(badgeID: "eco_enthusiast", userID: userID, value: activityCount)
        setProgress(badgeID: "eco_champion", userID: userID, value: activityCount)

        // Carbon achievements
        setProgress(badgeID: "carbon_cutter", userID: userID, value: profile.totalCarbonSavedKg)
        setProgress(badgeID: "carbon_crusher", userID: userID, value: profile.totalCarbonSavedKg)
        setProgress(badgeID: "carbon_hero", userID: userID, value: profile.totalCarbonSavedKg)

        // Water achievements
        setProgress(badgeID: "water_saver", userID: userID, value: profile.totalWaterSavedLiters)
        setProgress(badgeID: "water_guardian", userID: userID, value: profile.totalWaterSavedLiters)

        // Plastic achievements
        setProgress(badgeID: "plastic_fighter", userID: userID, value: Double(profile.totalPlasticSavedItems))
        setProgress(badgeID: "plastic_free", userID: userID, value: Double(profile.totalPlasticSavedItems))
        setProgress(badgeID: "ocean_protector", userID: userID, value: Double(profile.totalPlasticSavedItems))
    }

    /// Check and update streak achievements
    func checkStreakAchievements(userID: String, currentStreak: Int) {
        setProgress(badgeID: "week_warrior", userID: userID, value: Double(currentStreak))
        setProgress(badgeID: "monthly_master", userID: userID, value: Double(currentStreak))
        setProgress(badgeID: "streak_legend", userID: userID, value: Double(currentStreak))
    }

    /// Check and update level achievements
    func checkLevelAchievements(userID: String, currentLevel: Int) {
        setProgress(badgeID: "level_five", userID: userID, value: Double(currentLevel))
        setProgress(badgeID: "level_ten", userID: userID, value: Double(currentLevel))
        setProgress(badgeID: "level_twenty_five", userID: userID, value: Double(currentLevel))
    }

    /// Check and update waste sorting achievements
    func checkSortingAchievements(userID: String, correctSorts: Int) {
        setProgress(badgeID: "sorting_novice", userID: userID, value: Double(correctSorts))
        setProgress(badgeID: "sorting_pro", userID: userID, value: Double(correctSorts))
        setProgress(badgeID: "sorting_master", userID: userID, value: Double(correctSorts))
    }

    /// Check and update challenge completion achievements
    func checkChallengeAchievements(userID: String, completedChallenges: Int) {
        setProgress(badgeID: "challenge_completer", userID: userID, value: Double(completedChallenges))
        setProgress(badgeID: "challenge_champion", userID: userID, value: Double(completedChallenges))
    }

    // MARK: - Queries

    /// Get all achievements for a user
    func getAchievements(for userID: String) -> [Achievement] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<Achievement>(
            predicate: #Predicate<Achievement> { achievement in
                achievement.userID == userID
            },
            sortBy: [SortDescriptor(\.tier.rawValue), SortDescriptor(\.title)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("❌ AchievementService: Failed to fetch achievements: \(error.localizedDescription)")
            return []
        }
    }

    /// Get unlocked achievements for a user
    func getUnlockedAchievements(for userID: String) -> [Achievement] {
        getAchievements(for: userID).filter { $0.isUnlocked }
    }

    /// Get locked achievements for a user
    func getLockedAchievements(for userID: String) -> [Achievement] {
        getAchievements(for: userID).filter { !$0.isUnlocked }
    }

    /// Get a specific achievement
    func getAchievement(badgeID: String, userID: String) -> Achievement? {
        guard let context = modelContext else { return nil }

        let descriptor = FetchDescriptor<Achievement>(
            predicate: #Predicate<Achievement> { achievement in
                achievement.badgeID == badgeID && achievement.userID == userID
            }
        )

        do {
            return try context.fetch(descriptor).first
        } catch {
            print("❌ AchievementService: Failed to fetch achievement: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Unlock Handling

    private func handleUnlock(_ achievement: Achievement) {
        recentlyUnlocked.append(achievement)

        // Send notification
        notificationService?.notifyAchievementUnlocked(
            title: achievement.title,
            description: achievement.badgeDescription
        )

        print("🏆 AchievementService: Unlocked '\(achievement.title)'!")
    }

    /// Pop the next achievement to show in unlock overlay
    func popNextUnlock() -> Achievement? {
        guard !recentlyUnlocked.isEmpty else { return nil }
        return recentlyUnlocked.removeFirst()
    }

    /// Clear all pending unlocks (user dismissed overlay)
    func clearPendingUnlocks() {
        recentlyUnlocked.removeAll()
    }

    // MARK: - Private Helpers

    private func saveContext() {
        guard let context = modelContext else { return }
        do {
            try context.save()
        } catch {
            print("❌ AchievementService: Failed to save context: \(error.localizedDescription)")
        }
    }
}
