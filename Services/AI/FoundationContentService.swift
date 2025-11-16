//
//  FoundationContentService.swift
//  Eco Hero
//
//  Created by Rishabh Bansal on 11/15/25.
//

import Foundation
import Observation

#if canImport(FoundationModels)
import FoundationModels

@Generable
struct ActivityIdea {
    @Guide(description: "A concise action label like 'Walk to the store' or 'Prep veggie lunch'.")
    var actionTitle: String

    @Guide(description: "One sentence describing what to log, tailored to the Eco Hero categories.")
    var activityDescription: String

    @Guide(description: "A motivating note referencing impact (CO₂, water, waste).")
    var motivation: String
}

@Generable
struct ChallengeBlueprint {
    @Guide(description: "Snappy mission title fewer than 5 words.")
    var title: String

    @Guide(description: "One sentence challenge summary.")
    var summary: String

    @Guide(description: "One of: daily, weekly, milestone.")
    var cadence: String

    @Guide(description: "Eco category focus such as Meals, Transport, Plastic, Energy, Water, Lifestyle.")
    var category: String

    @Guide(description: "SF Symbol name that fits the mission.")
    var symbolName: String

    @Guide(description: "Number of actions needed (1-14).", .range(1...14))
    var targetCount: Int

    @Guide(description: "XP reward between 10 and 250.", .range(10...250))
    var rewardXP: Int
}

@Observable
final class FoundationContentService {
    private let activitySession: LanguageModelSession
    private let challengeSession: LanguageModelSession

    init() {
        activitySession = LanguageModelSession(
            instructions: """
            You are part of the Eco Hero app on iOS 26. Use upbeat eco language.
            Suggest log activities with clear motivation and respect the selected category.
            """
        )

        challengeSession = LanguageModelSession(
            instructions: """
            Generate sustainability challenges for Eco Hero players.
            Challenges should feel game-like with clear cadence (daily/weekly/milestone).
            Include SF Symbol references and realistic target counts.
            """
        )
    }

    func suggestActivity(for category: ActivityCategory) async throws -> ActivityIdea {
        let prompt = """
        Create a fresh log idea for the \(category.rawValue) category. Keep it actionable and motivating.
        """
        return try await activitySession.respond(
            to: prompt,
            generating: ActivityIdea.self
        ).content
    }

    func generateChallenge() async throws -> ChallengeBlueprint {
        let prompt = """
        Create a new Eco Hero mission. Keep it inspiring and vary the cadence and category.
        """
        return try await challengeSession.respond(
            to: prompt,
            generating: ChallengeBlueprint.self
        ).content
    }
}

#else

struct ActivityIdea {
    var actionTitle: String
    var activityDescription: String
    var motivation: String
}

struct ChallengeBlueprint {
    var title: String
    var summary: String
    var cadence: String
    var category: String
    var symbolName: String
    var targetCount: Int
    var rewardXP: Int
}

@Observable
final class FoundationContentService {
    private let fallbackIdeas: [ActivityCategory: ActivityIdea] = [
        .meals: ActivityIdea(
            actionTitle: "Prep Veggie Bowl",
            activityDescription: "Make a plant-heavy lunch with local produce.",
            motivation: "Plant-forward meals cut CO₂ and save thousands of liters of water."
        ),
        .transport: ActivityIdea(
            actionTitle: "Bike Errand",
            activityDescription: "Swap one short errand with a bike ride.",
            motivation: "Skipping a 5 km car ride saves ~600g CO₂."
        ),
        .plastic: ActivityIdea(
            actionTitle: "Refill Kit",
            activityDescription: "Take jars or totes to a refill shop.",
            motivation: "Every reuse avoids single-use plastics heading to landfills."
        ),
        .energy: ActivityIdea(
            actionTitle: "Lights-Off Sweep",
            activityDescription: "Unplug idle chargers and switch to LEDs.",
            motivation: "LEDs use 75% less power than incandescents."
        ),
        .water: ActivityIdea(
            actionTitle: "5-Minute Showers",
            activityDescription: "Set a timer and keep showers short.",
            motivation: "Quick showers save more than 10 liters each session."
        ),
        .lifestyle: ActivityIdea(
            actionTitle: "Sort & Compost",
            activityDescription: "Organize bins for recycle, compost, and trash.",
            motivation: "Separation keeps organic matter out of landfills."
        )
    ]

    private let fallbackChallenges: [ChallengeBlueprint] = [
        ChallengeBlueprint(
            title: "Transit Streak",
            summary: "Use public transport three times this week.",
            cadence: "weekly",
            category: "Transport",
            symbolName: "tram.fill",
            targetCount: 3,
            rewardXP: 120
        ),
        ChallengeBlueprint(
            title: "Hydro Hero",
            summary: "Log five water-saving actions in seven days.",
            cadence: "weekly",
            category: "Water",
            symbolName: "drop.circle.fill",
            targetCount: 5,
            rewardXP: 150
        ),
        ChallengeBlueprint(
            title: "Zero Plastic Day",
            summary: "Avoid single-use plastics for one full day.",
            cadence: "daily",
            category: "Plastic",
            symbolName: "bag.fill",
            targetCount: 1,
            rewardXP: 80
        )
    ]

    private var challengeIndex = 0

    init() {}

    func suggestActivity(for category: ActivityCategory) async throws -> ActivityIdea {
        if let idea = fallbackIdeas[category] {
            return idea
        }
        return ActivityIdea(
            actionTitle: "Eco Action",
            activityDescription: "Pick any small sustainable habit.",
            motivation: "Stacking small wins keeps your eco momentum going."
        )
    }

    func generateChallenge() async throws -> ChallengeBlueprint {
        guard !fallbackChallenges.isEmpty else {
            return ChallengeBlueprint(
                title: "Daily Habit",
                summary: "Complete any eco-friendly action today.",
                cadence: "daily",
                category: "Lifestyle",
                symbolName: "leaf.fill",
                targetCount: 1,
                rewardXP: 50
            )
        }

        let challenge = fallbackChallenges[challengeIndex % fallbackChallenges.count]
        challengeIndex += 1
        return challenge
    }
}

#endif
