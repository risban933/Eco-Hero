//
//  ImpactReportView.swift
//  Eco Hero
//
//  Environmental impact report view for PDF generation and display.
//
//  Created by Rishabh Bansal on 11/15/25.
//

import SwiftUI

struct ImpactReportView: View {
    let stats: ImpactStats
    let userName: String

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            reportHeader

            // Main content
            VStack(spacing: 24) {
                // Impact summary section
                impactSummarySection

                // Detailed breakdown
                detailedBreakdownSection

                // Equivalencies section
                equivalenciesSection

                // Activity summary
                activitySummarySection
            }
            .padding(32)

            Spacer()

            // Footer
            reportFooter
        }
        .background(Color.white)
    }

    // MARK: - Header

    private var reportHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.green)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Eco Hero")
                        .font(.title.bold())
                        .foregroundStyle(.primary)
                    Text("Environmental Impact Report")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(userName)
                        .font(.headline)
                    Text(stats.period.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(dateFormatter.string(from: Date()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color.green.opacity(0.15), Color.green.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    // MARK: - Impact Summary

    private var impactSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Your Impact", icon: "chart.bar.fill")

            HStack(spacing: 16) {
                impactCard(
                    value: String(format: "%.1f", stats.carbonSavedKg),
                    unit: "kg",
                    label: "CO₂ Saved",
                    icon: "cloud.fill",
                    color: .blue
                )

                impactCard(
                    value: String(format: "%.0f", stats.waterSavedLiters),
                    unit: "L",
                    label: "Water Saved",
                    icon: "drop.fill",
                    color: .cyan
                )

                impactCard(
                    value: "\(stats.plasticSavedItems)",
                    unit: "items",
                    label: "Plastic Avoided",
                    icon: "bag.fill",
                    color: .orange
                )
            }
        }
    }

    private func impactCard(value: String, unit: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2.bold())
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Detailed Breakdown

    private var detailedBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Activity Breakdown", icon: "list.bullet.clipboard.fill")

            VStack(spacing: 12) {
                breakdownRow(label: "Total Activities Logged", value: "\(stats.activitiesLogged)")
                breakdownRow(label: "Current Streak", value: "\(stats.currentStreak) days")
                breakdownRow(label: "Current Level", value: "Level \(stats.currentLevel)")
                breakdownRow(label: "Achievements Unlocked", value: "\(stats.achievementsUnlocked)")
            }
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private func breakdownRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
        }
    }

    // MARK: - Equivalencies

    private var equivalenciesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "What This Means", icon: "lightbulb.fill")

            VStack(spacing: 12) {
                equivalencyRow(
                    icon: "car.fill",
                    text: "Equivalent to \(Int(stats.carbonSavedKg / 0.21)) km not driven"
                )
                equivalencyRow(
                    icon: "shower.fill",
                    text: "Equivalent to \(Int(stats.waterSavedLiters / 65)) showers saved"
                )
                equivalencyRow(
                    icon: "tree.fill",
                    text: "Like planting \(max(1, Int(stats.carbonSavedKg / 21))) trees"
                )
            }
            .padding(16)
            .background(Color.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private func equivalencyRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.green)
                .frame(width: 30)

            Text(text)
                .font(.subheadline)
        }
    }

    // MARK: - Activity Summary

    private var activitySummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Your Journey", icon: "flag.checkered")

            HStack(spacing: 20) {
                journeyStatBox(value: "\(stats.currentStreak)", label: "Day Streak", icon: "flame.fill", color: .orange)
                journeyStatBox(value: "Lvl \(stats.currentLevel)", label: "Current Level", icon: "star.fill", color: .yellow)
                journeyStatBox(value: "\(stats.achievementsUnlocked)", label: "Badges", icon: "medal.fill", color: .purple)
            }
        }
    }

    private func journeyStatBox(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.headline)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Footer

    private var reportFooter: some View {
        VStack(spacing: 8) {
            Text("Generated by Eco Hero")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Every action counts towards a sustainable future 🌍")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.green)
            Text(title)
                .font(.headline)
        }
    }
}

// MARK: - Preview

#Preview {
    ImpactReportView(
        stats: ImpactStats(
            carbonSavedKg: 127.5,
            waterSavedLiters: 2450,
            plasticSavedItems: 89,
            activitiesLogged: 156,
            currentStreak: 14,
            currentLevel: 8,
            achievementsUnlocked: 12,
            period: .month
        ),
        userName: "John Doe"
    )
    .frame(width: 612, height: 792)
}
