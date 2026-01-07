//
//  EcoHeroWidget.swift
//  Eco Hero Widget
//
//  Widget extension for displaying eco impact at a glance.
//
//  Created by Rishabh Bansal on 11/15/25.
//

import WidgetKit
import SwiftUI

@main
struct EcoHeroWidgetBundle: WidgetBundle {
    var body: some Widget {
        EcoHeroWidget()
    }
}

struct EcoHeroWidget: Widget {
    let kind: String = "EcoHeroWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: EcoHeroProvider()) { entry in
            EcoHeroWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Eco Hero")
        .description("Track your environmental impact at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget Entry

struct EcoHeroEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let level: Int
    let xpProgress: Double
    let carbonSavedKg: Double
    let waterSavedLiters: Double
    let plasticSavedItems: Int
    let displayName: String
}

// MARK: - Timeline Provider

struct EcoHeroProvider: TimelineProvider {
    func placeholder(in context: Context) -> EcoHeroEntry {
        EcoHeroEntry(
            date: Date(),
            streak: 7,
            level: 5,
            xpProgress: 0.6,
            carbonSavedKg: 45.5,
            waterSavedLiters: 1250,
            plasticSavedItems: 32,
            displayName: "Eco Hero"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (EcoHeroEntry) -> Void) {
        let entry = loadUserData() ?? placeholder(in: context)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<EcoHeroEntry>) -> Void) {
        let entry = loadUserData() ?? placeholder(in: context)

        // Refresh every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }

    private func loadUserData() -> EcoHeroEntry? {
        // Load from shared UserDefaults (App Group)
        guard let defaults = UserDefaults(suiteName: "group.eco.hero.shared") else {
            return nil
        }

        return EcoHeroEntry(
            date: Date(),
            streak: defaults.integer(forKey: "streak"),
            level: max(1, defaults.integer(forKey: "level")),
            xpProgress: defaults.double(forKey: "xpProgress"),
            carbonSavedKg: defaults.double(forKey: "carbonSavedKg"),
            waterSavedLiters: defaults.double(forKey: "waterSavedLiters"),
            plasticSavedItems: defaults.integer(forKey: "plasticSavedItems"),
            displayName: defaults.string(forKey: "displayName") ?? "Eco Hero"
        )
    }
}

// MARK: - Widget Views

struct EcoHeroWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: EcoHeroEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: EcoHeroEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(.green)
                    .font(.title3)
                Text("Eco Hero")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Streak
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(entry.streak)")
                        .font(.title.bold())
                    Text("day streak")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            // Level progress
            VStack(alignment: .leading, spacing: 4) {
                Text("Level \(entry.level)")
                    .font(.caption.bold())

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.green)
                            .frame(width: geo.size.width * entry.xpProgress, height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding()
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: EcoHeroEntry

    var body: some View {
        HStack(spacing: 16) {
            // Left side - Streak & Level
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(.green)
                    Text("Eco Hero")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                        .font(.title)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(entry.streak)")
                            .font(.title.bold())
                        Text("day streak")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                // Level
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level \(entry.level)")
                        .font(.caption.bold())

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.green)
                                .frame(width: geo.size.width * entry.xpProgress, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // Right side - Stats
            VStack(spacing: 10) {
                statRow(icon: "cloud.fill", value: String(format: "%.1f", entry.carbonSavedKg), unit: "kg CO₂", color: .blue)
                statRow(icon: "drop.fill", value: String(format: "%.0f", entry.waterSavedLiters), unit: "L water", color: .cyan)
                statRow(icon: "bag.fill", value: "\(entry.plasticSavedItems)", unit: "plastics", color: .orange)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
    }

    private func statRow(icon: String, value: String, unit: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.caption)
                .frame(width: 16)

            Text(value)
                .font(.caption.bold())

            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    EcoHeroWidget()
} timeline: {
    EcoHeroEntry(
        date: Date(),
        streak: 14,
        level: 8,
        xpProgress: 0.65,
        carbonSavedKg: 127.5,
        waterSavedLiters: 2450,
        plasticSavedItems: 89,
        displayName: "John"
    )
}

#Preview(as: .systemMedium) {
    EcoHeroWidget()
} timeline: {
    EcoHeroEntry(
        date: Date(),
        streak: 14,
        level: 8,
        xpProgress: 0.65,
        carbonSavedKg: 127.5,
        waterSavedLiters: 2450,
        plasticSavedItems: 89,
        displayName: "John"
    )
}
