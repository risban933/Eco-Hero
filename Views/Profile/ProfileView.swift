//
//  ProfileView.swift
//  Eco Hero
//
//  Created by Rishabh Bansal on 11/15/25.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    var embedInNavigation: Bool = true
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthenticationManager.self) private var authManager
    @Query private var profiles: [UserProfile]
    @Query private var activities: [EcoActivity]
    @Query private var achievements: [Achievement]

    @State private var showingSettings = false
    @State private var showingLogoutAlert = false

    private var userProfile: UserProfile? {
        profiles.first { $0.userIdentifier == authManager.currentUserID ?? "" }
    }

    private var unlockedAchievements: [Achievement] {
        achievements.filter { $0.userID == authManager.currentUserID && $0.isUnlocked }
    }

    var body: some View {
        Group {
            if embedInNavigation {
                NavigationStack {
                    content
                        .navigationTitle("Profile")
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    showingSettings = true
                                } label: {
                                    Image(systemName: "gearshape")
                                }
                            }
                        }
                }
            } else {
                content
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .alert("Sign Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }

    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppConstants.Layout.sectionSpacing) {
                profileHeader
                statsOverview
                achievementsSummary
                activityHistory
                settingsSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
        }
        .background(
            LinearGradient(
                colors: [AppConstants.Colors.sand, Color(.systemGroupedBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppConstants.Gradients.accent)
                        .frame(width: 90, height: 90)
                    Text(userProfile?.displayName.prefix(1).uppercased() ?? "E")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(userProfile?.displayName ?? "Eco Hero")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    if let profile = userProfile {
                        Text(AppConstants.Levels.levelTitle(for: profile.currentLevel))
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    if let email = authManager.currentUserEmail {
                        Text(email)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                Spacer()
            }

            if let profile = userProfile {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Level \(profile.currentLevel)")
                            .font(.footnote.bold())
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(0.2), in: Capsule())
                        Text("\(profile.streak) day streak")
                            .font(.footnote)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(0.12), in: Capsule())
                    }

                    ProgressView(value: profile.experiencePoints, total: Double(max(profile.currentLevel * 100, 1)))
                        .tint(.white)

                    Text("XP \(Int(profile.experiencePoints)) of \(profile.currentLevel * 100)")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [AppConstants.Colors.evergreen, AppConstants.Colors.ocean],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        )
        .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 10)
    }

    private var statsOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Impact snapshots")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ProfileStatCard(
                    title: "CO₂ Saved",
                    value: userProfile?.totalCarbonSavedKg ?? 0,
                    unit: "kg",
                    icon: "cloud.fill",
                    tint: .green
                )

                ProfileStatCard(
                    title: "Water Saved",
                    value: userProfile?.totalWaterSavedLiters ?? 0,
                    unit: "L",
                    icon: "drop.fill",
                    tint: .blue
                )

                ProfileStatCard(
                    title: "Activities",
                    value: Double(activities.count),
                    unit: "total",
                    icon: "checkmark.circle.fill",
                    tint: .indigo
                )

                ProfileStatCard(
                    title: "Longest streak",
                    value: Double(userProfile?.longestStreak ?? 0),
                    unit: "days",
                    icon: "flame.fill",
                    tint: .orange
                )
            }
        }
    }

    private var achievementsSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Badges")
                    .font(.headline)
                Spacer()
                NavigationLink("View All") {
                    AchievementsListView()
                }
                .font(.footnote.bold())
            }

            if unlockedAchievements.isEmpty {
                EmptyStateView(icon: "sparkles", title: "No badges yet", message: "Complete challenges to start your badge collection.")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(unlockedAchievements.prefix(10)) { achievement in
                            AchievementBadgeView(achievement: achievement)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }

    private var activityHistory: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                Spacer()
                NavigationLink("View All") {
                    ActivitiesListView()
                }
                .font(.footnote.bold())
            }

            if activities.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "leaf.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)

                    Text("No activities yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .cardStyle()
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(activities.prefix(4))) { activity in
                        ActivityRowView(activity: activity)
                    }
                }
            }
        }
    }

    private var settingsSection: some View {
        VStack(spacing: 0) {
            Button {
                showingSettings = true
            } label: {
                HStack {
                    Label("Preferences", systemImage: "gearshape")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            Divider()

            Button {
                showingLogoutAlert = true
            } label: {
                HStack {
                    Label("Sign Out", systemImage: "arrow.right.square")
                    Spacer()
                }
                .foregroundStyle(.red)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .cardStyle()
    }

    private func signOut() {
        do {
            try authManager.signOut()
        } catch {
            print("Error signing out: \(error)")
        }
    }
}

struct ProfileStatCard: View {
    let title: String
    let value: Double
    let unit: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .padding(10)
                .background(tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text(value.abbreviated)
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(AppConstants.Layout.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Environment(AuthenticationManager.self) private var authManager

    private var userProfile: UserProfile? {
        profiles.first { $0.userIdentifier == authManager.currentUserID ?? "" }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Toggle("Sound Effects", isOn: Binding(
                        get: { userProfile?.soundEnabled ?? true },
                        set: { newValue in
                            if let profile = userProfile {
                                profile.soundEnabled = newValue
                            }
                        }
                    ))

                    Toggle("Haptic Feedback", isOn: Binding(
                        get: { userProfile?.hapticsEnabled ?? true },
                        set: { newValue in
                            if let profile = userProfile {
                                profile.hapticsEnabled = newValue
                            }
                        }
                    ))

                    Toggle("Notifications", isOn: Binding(
                        get: { userProfile?.notificationsEnabled ?? true },
                        set: { newValue in
                            if let profile = userProfile {
                                profile.notificationsEnabled = newValue
                            }
                        }
                    ))
                }

                Section("Account") {
                    if let email = authManager.currentUserEmail {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(email)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AchievementsListView: View {
    @Query private var achievements: [Achievement]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 16) {
                ForEach(achievements) { achievement in
                    AchievementBadgeView(achievement: achievement)
                }
            }
            .padding()
        }
        .navigationTitle("Achievements")
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    ProfileView()
        .environment(AuthenticationManager())
        .modelContainer(for: [UserProfile.self, EcoActivity.self], inMemory: true)
}
