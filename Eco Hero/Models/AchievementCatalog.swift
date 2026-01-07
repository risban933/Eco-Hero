//
//  AchievementCatalog.swift
//  Eco Hero
//
//  Defines all available achievements in the app.
//
//  Created by Rishabh Bansal on 11/15/25.
//

import Foundation

/// Catalog of all achievements available in Eco Hero
enum AchievementCatalog {

    /// Achievement definition for creating achievements
    struct AchievementDefinition {
        let badgeID: String
        let title: String
        let description: String
        let tier: AchievementTier
        let iconName: String
        let category: ActivityCategory?
        let progressRequired: Double

        init(
            badgeID: String,
            title: String,
            description: String,
            tier: AchievementTier,
            iconName: String,
            category: ActivityCategory? = nil,
            progressRequired: Double
        ) {
            self.badgeID = badgeID
            self.title = title
            self.description = description
            self.tier = tier
            self.iconName = iconName
            self.category = category
            self.progressRequired = progressRequired
        }
    }

    // MARK: - Getting Started Achievements

    static let firstSteps = AchievementDefinition(
        badgeID: "first_steps",
        title: "First Steps",
        description: "Log your first eco-friendly activity",
        tier: .bronze,
        iconName: "leaf.fill",
        progressRequired: 1
    )

    static let gettingStarted = AchievementDefinition(
        badgeID: "getting_started",
        title: "Getting Started",
        description: "Log 5 eco-friendly activities",
        tier: .bronze,
        iconName: "star.fill",
        progressRequired: 5
    )

    static let ecoEnthusiast = AchievementDefinition(
        badgeID: "eco_enthusiast",
        title: "Eco Enthusiast",
        description: "Log 25 eco-friendly activities",
        tier: .silver,
        iconName: "star.circle.fill",
        progressRequired: 25
    )

    static let ecoChampion = AchievementDefinition(
        badgeID: "eco_champion",
        title: "Eco Champion",
        description: "Log 100 eco-friendly activities",
        tier: .gold,
        iconName: "trophy.fill",
        progressRequired: 100
    )

    // MARK: - Streak Achievements

    static let weekWarrior = AchievementDefinition(
        badgeID: "week_warrior",
        title: "Week Warrior",
        description: "Maintain a 7-day streak",
        tier: .bronze,
        iconName: "flame.fill",
        progressRequired: 7
    )

    static let monthlyMaster = AchievementDefinition(
        badgeID: "monthly_master",
        title: "Monthly Master",
        description: "Maintain a 30-day streak",
        tier: .silver,
        iconName: "flame.circle.fill",
        progressRequired: 30
    )

    static let streakLegend = AchievementDefinition(
        badgeID: "streak_legend",
        title: "Streak Legend",
        description: "Maintain a 100-day streak",
        tier: .platinum,
        iconName: "flame.circle",
        progressRequired: 100
    )

    // MARK: - Carbon Achievements

    static let carbonCutter = AchievementDefinition(
        badgeID: "carbon_cutter",
        title: "Carbon Cutter",
        description: "Save 10 kg of CO₂",
        tier: .bronze,
        iconName: "cloud.fill",
        progressRequired: 10
    )

    static let carbonCrusher = AchievementDefinition(
        badgeID: "carbon_crusher",
        title: "Carbon Crusher",
        description: "Save 100 kg of CO₂",
        tier: .silver,
        iconName: "cloud.sun.fill",
        progressRequired: 100
    )

    static let carbonHero = AchievementDefinition(
        badgeID: "carbon_hero",
        title: "Carbon Hero",
        description: "Save 1,000 kg of CO₂",
        tier: .gold,
        iconName: "sun.max.fill",
        progressRequired: 1000
    )

    // MARK: - Water Achievements

    static let waterSaver = AchievementDefinition(
        badgeID: "water_saver",
        title: "Water Saver",
        description: "Save 100 liters of water",
        tier: .bronze,
        iconName: "drop.fill",
        category: .water,
        progressRequired: 100
    )

    static let waterGuardian = AchievementDefinition(
        badgeID: "water_guardian",
        title: "Water Guardian",
        description: "Save 1,000 liters of water",
        tier: .silver,
        iconName: "drop.circle.fill",
        category: .water,
        progressRequired: 1000
    )

    // MARK: - Plastic Achievements

    static let plasticFighter = AchievementDefinition(
        badgeID: "plastic_fighter",
        title: "Plastic Fighter",
        description: "Avoid 10 single-use plastic items",
        tier: .bronze,
        iconName: "bag.fill",
        category: .plastic,
        progressRequired: 10
    )

    static let plasticFree = AchievementDefinition(
        badgeID: "plastic_free",
        title: "Plastic Free",
        description: "Avoid 50 single-use plastic items",
        tier: .silver,
        iconName: "bag.circle.fill",
        category: .plastic,
        progressRequired: 50
    )

    static let oceanProtector = AchievementDefinition(
        badgeID: "ocean_protector",
        title: "Ocean Protector",
        description: "Avoid 200 single-use plastic items",
        tier: .gold,
        iconName: "water.waves",
        category: .plastic,
        progressRequired: 200
    )

    // MARK: - Waste Sorting Achievements

    static let sortingNovice = AchievementDefinition(
        badgeID: "sorting_novice",
        title: "Sorting Novice",
        description: "Correctly sort 10 items in the waste game",
        tier: .bronze,
        iconName: "arrow.3.trianglepath",
        progressRequired: 10
    )

    static let sortingPro = AchievementDefinition(
        badgeID: "sorting_pro",
        title: "Sorting Pro",
        description: "Correctly sort 50 items in the waste game",
        tier: .silver,
        iconName: "arrow.triangle.2.circlepath",
        progressRequired: 50
    )

    static let sortingMaster = AchievementDefinition(
        badgeID: "sorting_master",
        title: "Sorting Master",
        description: "Correctly sort 100 items with 90%+ accuracy",
        tier: .gold,
        iconName: "checkmark.seal.fill",
        progressRequired: 100
    )

    // MARK: - Level Achievements

    static let levelFive = AchievementDefinition(
        badgeID: "level_five",
        title: "Rising Star",
        description: "Reach level 5",
        tier: .bronze,
        iconName: "5.circle.fill",
        progressRequired: 5
    )

    static let levelTen = AchievementDefinition(
        badgeID: "level_ten",
        title: "Eco Veteran",
        description: "Reach level 10",
        tier: .silver,
        iconName: "10.circle.fill",
        progressRequired: 10
    )

    static let levelTwentyFive = AchievementDefinition(
        badgeID: "level_twenty_five",
        title: "Eco Legend",
        description: "Reach level 25",
        tier: .gold,
        iconName: "25.circle.fill",
        progressRequired: 25
    )

    // MARK: - Challenge Achievements

    static let challengeCompleter = AchievementDefinition(
        badgeID: "challenge_completer",
        title: "Challenge Completer",
        description: "Complete your first challenge",
        tier: .bronze,
        iconName: "flag.fill",
        progressRequired: 1
    )

    static let challengeChampion = AchievementDefinition(
        badgeID: "challenge_champion",
        title: "Challenge Champion",
        description: "Complete 10 challenges",
        tier: .silver,
        iconName: "flag.checkered",
        progressRequired: 10
    )

    // MARK: - All Achievements List

    static let allDefinitions: [AchievementDefinition] = [
        // Getting Started
        firstSteps,
        gettingStarted,
        ecoEnthusiast,
        ecoChampion,

        // Streaks
        weekWarrior,
        monthlyMaster,
        streakLegend,

        // Carbon
        carbonCutter,
        carbonCrusher,
        carbonHero,

        // Water
        waterSaver,
        waterGuardian,

        // Plastic
        plasticFighter,
        plasticFree,
        oceanProtector,

        // Waste Sorting
        sortingNovice,
        sortingPro,
        sortingMaster,

        // Levels
        levelFive,
        levelTen,
        levelTwentyFive,

        // Challenges
        challengeCompleter,
        challengeChampion
    ]

    /// Get achievement definition by badge ID
    static func definition(for badgeID: String) -> AchievementDefinition? {
        allDefinitions.first { $0.badgeID == badgeID }
    }
}
