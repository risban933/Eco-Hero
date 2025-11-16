//
//  TipModelService.swift
//  Eco Hero
//
//  Created by Rishabh Bansal on 11/15/25.
//

import CoreML
import Observation

@Observable
class TipModelService {
    private let model: EcoTipRecommender?
    private let categories: [String]

    init(configuration: MLModelConfiguration = MLModelConfiguration()) {
        self.model = try? EcoTipRecommender(configuration: configuration)
        if let metadata = model?.model.modelDescription.metadata[.creatorDefinedKey] as? [String: String],
           let categoryList = metadata["categories"] {
            self.categories = categoryList.split(separator: ",").map { String($0) }
        } else {
            self.categories = ["meals", "transport", "plastic", "energy", "water", "lifestyle"]
        }
    }

    func generateTip(for category: ActivityCategory) -> String {
        guard let model else {
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
