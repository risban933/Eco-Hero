//
//  LearnView.swift
//  Eco Hero
//
//  Created by Rishabh Bansal on 11/15/25.
//

import SwiftUI

struct LearnView: View {
    var embedInNavigation: Bool = true
    @Environment(TipModelService.self) private var tipModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedCategory: ActivityCategory = .meals
    @State private var smartTip: String?
    @State private var factOfDay: String = AppConstants.EducationalFacts.randomFact()
    @Namespace private var glassNamespace

    var body: some View {
        Group {
            if embedInNavigation {
                NavigationStack {
                    content
                        .navigationTitle("Learn")
                }
            } else {
                content
            }
        }
    }

    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppConstants.Layout.sectionSpacing) {
                dailyFactCard
                tipsSection
                smartTipSection
                allFactsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
        .background(
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color.green.opacity(0.3), Color.black]
                    : [Color.green.opacity(0.15), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    private var dailyFactCard: some View {
        GlassEffectContainer(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Eco fact of the day", systemImage: "globe.asia.australia.fill")
                        .font(.headline)
                    Spacer()
                    Button {
                        withAnimation(.spring) {
                            factOfDay = AppConstants.EducationalFacts.randomFact()
                        }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    .buttonStyle(.glass(.regular.interactive()))
                    .glassEffectID("refresh-fact", in: glassNamespace)
                }

                Text(factOfDay)
                    .font(.body)
                    .foregroundStyle(.white)

                Text("Share this insight with a friend today.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(24)
            .glassEffect(.regular.tint(Color.ecoGreen.opacity(0.4)), in: .rect(cornerRadius: 28))
            .glassEffectID("daily-fact", in: glassNamespace)
        }
        .shadow(color: Color.black.opacity(0.2), radius: 24, x: 0, y: 12)
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Guided topics")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                ForEach(ActivityCategory.allCases, id: \.self) { category in
                    CategoryTipCard(category: category)
                }
            }
        }
    }

    private var smartTipSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Smart tip generator")
                    .font(.headline)
                Spacer()
                if tipModel.isGenerating {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }

            Picker("Focus Area", selection: $selectedCategory) {
                ForEach(ActivityCategory.allCases, id: \.self) { category in
                    Text(category.rawValue)
                        .tag(category)
                }
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 8) {
                if tipModel.isGenerating && !tipModel.streamedTip.isEmpty {
                    Text(tipModel.streamedTip)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .animation(.easeInOut(duration: 0.1), value: tipModel.streamedTip)
                } else if let tip = smartTip, !tip.isEmpty {
                    Text(tip)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("Tap below to generate an AI-powered tip using Apple Intelligence.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .frame(minHeight: 80)

            GlassEffectContainer(spacing: 0) {
                Button(action: generateSmartTip) {
                    Label(
                        tipModel.isGenerating ? "Generating..." : "Generate Smart Tip",
                        systemImage: tipModel.isGenerating ? "sparkles" : "bolt.fill"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                }
                .buttonStyle(.glass(.regular.tint(AppConstants.Colors.ocean.opacity(0.6)).interactive()))
                .glassEffectID("generate-tip", in: glassNamespace)
                .disabled(tipModel.isGenerating)
                .opacity(tipModel.isGenerating ? 0.7 : 1.0)
            }
        }
        .cardStyle()
        .onAppear {
            if smartTip == nil {
                smartTip = tipModel.generateTip(for: selectedCategory)
            }
        }
    }

    private var allFactsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Eco knowledge library")
                .font(.headline)
            LazyVStack(spacing: 12) {
                ForEach(Array(AppConstants.EducationalFacts.facts.enumerated()), id: \.offset) { index, fact in
                    FactCard(fact: fact, number: index + 1)
                }
            }
        }
    }

    private func generateSmartTip() {
        Task {
            await tipModel.generateStreamingTip(for: selectedCategory)
            smartTip = tipModel.streamedTip
        }
    }
}


struct CategoryTipCard: View {
    let category: ActivityCategory

    var body: some View {
        NavigationLink(destination: CategoryTipsDetailView(category: category)) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundStyle(category.color)
                    .padding(12)
                    .background(category.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                Text(category.rawValue)
                    .font(.headline)
                Text("Explore tips and actions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(AppConstants.Layout.cardCornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct FactCard: View {
    let fact: String
    let number: Int

    var body: some View {
        HStack(spacing: 12) {
            Text("#\(number)")
                .font(.caption.bold())
                .padding(10)
                .background(Color.ecoGreen.opacity(0.15), in: Circle())
            Text(fact)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(AppConstants.Layout.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

struct CategoryTipsDetailView: View {
    let category: ActivityCategory

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: category.icon)
                        .font(.system(size: 48))
                        .foregroundStyle(category.color)
                    Text(category.rawValue)
                        .font(.largeTitle.bold())
                    Text("Tips and information about \(category.rawValue.lowercased())")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(category.color.opacity(0.12))
                .cornerRadius(24)

                if let tip = AppConstants.EcoTips.tip(for: category) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(tip.title)
                            .font(.title2.bold())
                        Text(tip.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .cardStyle()
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Did you know?")
                        .font(.headline)
                    ForEach(Array(AppConstants.EducationalFacts.facts.prefix(3).enumerated()), id: \.offset) { index, fact in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(.yellow)
                            Text(fact)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LearnView()
        .environment(TipModelService())
}

#Preview("Category Detail") {
    NavigationStack {
        CategoryTipsDetailView(category: .meals)
    }
}
