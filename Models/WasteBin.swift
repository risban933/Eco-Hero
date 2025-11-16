//
//  WasteBin.swift
//  Eco Hero
//
//  Created by Rishabh Bansal on 11/15/25.
//

import Foundation
import SwiftUI

enum WasteBin: String, Codable, CaseIterable {
    case recycle = "Recycle"
    case compost = "Compost"

    var icon: String {
        switch self {
        case .recycle: return "arrow.3.trianglepath"
        case .compost: return "leaf.fill"
        }
    }

    var color: Color {
        switch self {
        case .recycle: return .blue
        case .compost: return .green
        }
    }
}
