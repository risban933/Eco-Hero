//
//  WasteSortingResult.swift
//  Eco Hero
//
//  Created by Rishabh Bansal on 11/15/25.
//

import Foundation
import SwiftData

@Model
final class WasteSortingResult {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var predictedBin: WasteBin
    var userSelection: WasteBin
    var isCorrect: Bool
    var confidence: Double
    var pointsAwarded: Int

    init(predictedBin: WasteBin,
         userSelection: WasteBin,
         isCorrect: Bool,
         confidence: Double,
         pointsAwarded: Int) {
        self.id = UUID()
        self.timestamp = Date()
        self.predictedBin = predictedBin
        self.userSelection = userSelection
        self.isCorrect = isCorrect
        self.confidence = confidence
        self.pointsAwarded = pointsAwarded
    }
}
