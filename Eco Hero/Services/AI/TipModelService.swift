//
//  TipModelService.swift
//  Eco Hero
//
//  Created by Rishabh Bansal on 11/15/25.
//

import CoreML
import Observation
#if canImport(FoundationModels)
import FoundationModels
#endif

@Observable
class TipModelService {
    private let legacyModel: EcoTipRecommender?
    private let categories: [String]

    // Foundation Models session for on-device AI (iOS 26+)
    #if canImport(FoundationModels)
    private var languageSession: LanguageModelSession?
    #endif
    var isGenerating = false
    var streamedTip = ""

    init(configuration: MLModelConfiguration = MLModelConfiguration()) {
        self.legacyModel = try? EcoTipRecommender(configuration: configuration)
        if let metadata = legacyModel?.model.modelDescription.metadata[.creatorDefinedKey] as? [String: String],
           let categoryList = metadata["categories"] {
            self.categories = categoryList.split(separator: ",").map { String($0) }
        } else {
            self.categories = ["meals", "transport", "plastic", "energy", "water", "lifestyle"]
        }

        // Initialize Foundation Models session with eco-friendly instructions
        setupLanguageSession()
    }

    private func setupLanguageSession() {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            languageSession = LanguageModelSession(instructions: """
                You are an expert environmental sustainability coach. Your role is to provide \
                actionable, specific, and encouraging eco-friendly tips. Keep tips concise (2-3 sentences), \
                practical for everyday life, and backed by real environmental impact. \
                Focus on positive actions rather than restrictions. Include specific metrics when relevant \
                (e.g., "saves X liters of water" or "reduces Y kg of CO₂").
                """)
        }
        #endif
    }

    // MARK: - Streaming Response (iOS 26+ Foundation Models)

    @MainActor
    func generateStreamingTip(for category: ActivityCategory) async {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            guard let session = languageSession else {
                streamedTip = fallbackTip(for: category)
                return
            }

            isGenerating = true
            streamedTip = ""

            let prompt = """
                Generate a specific, actionable eco-friendly tip for the category: \(category.rawValue).
                The tip should be practical, encouraging, and include the environmental impact.
                Keep it to 2-3 sentences maximum.
                """

            do {
                let responseStream = session.streamResponse(to: prompt)

                for try await snapshot in responseStream {
                    streamedTip = snapshot.content
                }
            } catch {
                streamedTip = fallbackTip(for: category)
            }

            isGenerating = false
            return
        }
        #endif

        // Fallback for older iOS versions
        streamedTip = fallbackTip(for: category)
    }

    // MARK: - Non-Streaming Response

    @MainActor
    func generateTipAsync(for category: ActivityCategory) async -> String {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            guard let session = languageSession else {
                return fallbackTip(for: category)
            }

            let prompt = """
                Generate a specific, actionable eco-friendly tip for the category: \(category.rawValue).
                The tip should be practical, encouraging, and include the environmental impact.
                Keep it to 2-3 sentences maximum.
                """

            do {
                let response = try await session.respond(to: prompt)
                return response.content
            } catch {
                return fallbackTip(for: category)
            }
        }
        #endif

        return fallbackTip(for: category)
    }

    // MARK: - Legacy CoreML Method (Fallback)

    func generateTip(for category: ActivityCategory) -> String {
        guard let model = legacyModel else {
            return fallbackTip(for: category)
        }

        let vector = oneHotVector(for: category)

        do {
            let prediction = try model.prediction(
                category_meals: vector["category_meals"] ?? 0,
                category_transport: vector["category_transport"] ?? 0,
                category_plastic: vector["category_plastic"] ?? 0,
                category_energy: vector["category_energy"] ?? 0,
                category_water: vector["category_water"] ?? 0,
                category_lifestyle: vector["category_lifestyle"] ?? 0
            )
            return prediction.tip
        } catch {
            return fallbackTip(for: category)
        }
    }

    private func oneHotVector(for category: ActivityCategory) -> [String: Double] {
        var vector: [String: Double] = [:]
        for cat in categories {
            vector["category_\(cat)"] = 0
        }
        let key = "category_\(category.rawValue.lowercased())"
        vector[key] = 1
        return vector
    }

    private func fallbackTip(for category: ActivityCategory) -> String {
        switch category {
        case .meals:
            return "Prepare a plant-forward meal to cut emissions and save water."
        case .transport:
            return "Plan a car-free errand using transit, cycling, or walking."
        case .plastic:
            return "Pack reusable containers to avoid single-use plastics today."
        case .energy:
            return "Unplug idle chargers and use LEDs to cut electricity waste."
        case .water:
            return "Set a five-minute shower timer to conserve fresh water."
        case .lifestyle:
            return "Sort recyclables properly and set up a small compost bin."
        case .other:
            return "Pick any small sustainable action—every habit counts."
        }
    }
}
