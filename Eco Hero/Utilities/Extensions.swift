//
//  Extensions.swift
//  Eco Hero
//
//  Created by Rishabh Bansal on 11/15/25.
//

import Foundation
import SwiftUI

// MARK: - Date Extensions

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: self) ?? self
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}

// MARK: - Double Extensions

extension Double {
    /// Format as decimal with specified decimal places
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    /// Format as string with comma separators
    var formattedWithCommas: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    /// Format for display (e.g., "1.2K", "3.4M")
    var abbreviated: String {
        let thousand = 1000.0
        let million = 1_000_000.0

        if self >= million {
            return String(format: "%.1fM", self / million)
        } else if self >= thousand {
            return String(format: "%.1fK", self / thousand)
        } else {
            return String(format: "%.1f", self)
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply a reusable elevated card appearance used throughout the refreshed UI
    func cardStyle(
        background: Color = AppConstants.Colors.elevatedSurface,
        cornerRadius: CGFloat = AppConstants.Layout.cardCornerRadius,
        shadowOpacity: Double = 0.08,
        borderOpacity: Double = 0.08
    ) -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(background)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(borderOpacity), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(shadowOpacity), radius: 20, x: 0, y: 8)
    }

    /// Glassmorphic variant for hero cards and authentication panels
    func glassCardStyle(cornerRadius: CGFloat = AppConstants.Layout.cardCornerRadius) -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(AppConstants.Gradients.mellow)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.15), radius: 30, x: 0, y: 20)
    }

    /// Style for pill shaped filter chips
    func pillStyle(background: Color, foreground: Color = .white) -> some View {
        self
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(
                Capsule()
                    .fill(background)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            )
            .foregroundStyle(foreground)
    }

    /// Add haptic feedback on tap
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
}

// MARK: - Color Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static let ecoGreen = Color(hex: "4CAF50")
    static let ecoBlue = Color(hex: "2196F3")
    static let ecoOrange = Color(hex: "FF9800")
}
