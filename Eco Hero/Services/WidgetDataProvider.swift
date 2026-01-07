//
//  WidgetDataProvider.swift
//  Eco Hero
//
//  Provides data sharing between the main app and widget extension.
//  Uses App Groups (group.eco.hero.shared) to share UserDefaults.
//
//  Created by Rishabh Bansal on 11/15/25.
//

import Foundation
import WidgetKit

/// Manages data sharing between main app and widget
final class WidgetDataProvider {

    static let shared = WidgetDataProvider()

    private let suiteName = "group.eco.hero.shared"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    private init() {}

    // MARK: - Update Widget Data

    /// Update all widget data from user profile
    func updateWidgetData(from profile: UserProfile) {
        guard let defaults = sharedDefaults else {
            print("⚠️ WidgetDataProvider: Could not access shared UserDefaults")
            return
        }

        defaults.set(profile.streak, forKey: "streak")
        defaults.set(profile.currentLevel, forKey: "level")

        // Calculate XP progress within current level
        let xpForCurrentLevel = Double(profile.currentLevel * 100)
        let xpProgress = min(profile.experiencePoints / xpForCurrentLevel, 1.0)
        defaults.set(xpProgress, forKey: "xpProgress")

        defaults.set(profile.totalCarbonSavedKg, forKey: "carbonSavedKg")
        defaults.set(profile.totalWaterSavedLiters, forKey: "waterSavedLiters")
        defaults.set(profile.totalPlasticSavedItems, forKey: "plasticSavedItems")
        defaults.set(profile.displayName, forKey: "displayName")

        // Trigger widget refresh
        reloadWidgets()

        print("✅ WidgetDataProvider: Updated widget data for \(profile.displayName)")
    }

    /// Update just the streak (called frequently)
    func updateStreak(_ streak: Int) {
        sharedDefaults?.set(streak, forKey: "streak")
        reloadWidgets()
    }

    /// Update level and XP progress
    func updateLevel(_ level: Int, xpProgress: Double) {
        sharedDefaults?.set(level, forKey: "level")
        sharedDefaults?.set(xpProgress, forKey: "xpProgress")
        reloadWidgets()
    }

    /// Update impact stats
    func updateImpactStats(carbon: Double, water: Double, plastic: Int) {
        sharedDefaults?.set(carbon, forKey: "carbonSavedKg")
        sharedDefaults?.set(water, forKey: "waterSavedLiters")
        sharedDefaults?.set(plastic, forKey: "plasticSavedItems")
        reloadWidgets()
    }

    // MARK: - Widget Reload

    /// Request widget timeline reload
    func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Reload specific widget
    func reloadWidget(kind: String = "EcoHeroWidget") {
        WidgetCenter.shared.reloadTimelines(ofKind: kind)
    }

    // MARK: - Clear Data

    /// Clear all widget data (on logout)
    func clearWidgetData() {
        guard let defaults = sharedDefaults else { return }

        defaults.removeObject(forKey: "streak")
        defaults.removeObject(forKey: "level")
        defaults.removeObject(forKey: "xpProgress")
        defaults.removeObject(forKey: "carbonSavedKg")
        defaults.removeObject(forKey: "waterSavedLiters")
        defaults.removeObject(forKey: "plasticSavedItems")
        defaults.removeObject(forKey: "displayName")

        reloadWidgets()
        print("🗑️ WidgetDataProvider: Cleared widget data")
    }
}

// MARK: - UserProfile Extension

extension UserProfile {
    /// Sync profile data to widget
    func syncToWidget() {
        WidgetDataProvider.shared.updateWidgetData(from: self)
    }
}
