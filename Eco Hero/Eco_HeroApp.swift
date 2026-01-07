//
//  Eco_HeroApp.swift
//  Eco Hero
//
//  Created by Rishabh Bansal on 11/15/25.
//

import SwiftUI
import SwiftData
import Observation

@main
struct Eco_HeroApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var authManager = AuthenticationManager()
    @State private var syncService = CloudSyncService()
    @State private var tipService = TipModelService()
    @State private var wasteClassifier = WasteClassifierService()
    @State private var foundationContentService = FoundationContentService()
    @State private var notificationService = NotificationService()
    @State private var challengeManager = ChallengeManager()
    @State private var achievementService = AchievementService()

    @State private var modelContainerError: Error?

    var sharedModelContainer: ModelContainer? = {
        print("🔄 App: Creating SwiftData ModelContainer...")

        let schema = Schema([
            EcoActivity.self,
            UserProfile.self,
            Challenge.self,
            Achievement.self,
            WasteSortingResult.self
        ])

        print("✅ App: Schema created with \(schema.entities.count) entities")

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("✅ App: ModelContainer created successfully")
            return container
        } catch {
            print("❌ App: ERROR - Could not create ModelContainer")
            print("❌ App: Error: \(error)")
            print("❌ App: Error details: \(error.localizedDescription)")

            if let nsError = error as NSError? {
                print("❌ App: Error domain: \(nsError.domain)")
                print("❌ App: Error code: \(nsError.code)")
                print("❌ App: Error userInfo: \(nsError.userInfo)")
            }

            // Return nil instead of crashing - we'll show an error view
            return nil
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if let container = sharedModelContainer {
                    ZStack {
                        if hasCompletedOnboarding {
                            if authManager.isAuthenticated {
                                MainTabView()
                                    .environment(authManager)
                                    .environment(syncService)
                                    .environment(tipService)
                                    .environment(wasteClassifier)
                                    .environment(foundationContentService)
                                    .environment(notificationService)
                                    .environment(challengeManager)
                                    .environment(achievementService)
                            } else {
                                AuthenticationView()
                                    .environment(authManager)
                                    .environment(syncService)
                                    .environment(tipService)
                                    .environment(wasteClassifier)
                                    .environment(foundationContentService)
                                    .environment(notificationService)
                                    .environment(achievementService)
                            }
                        } else {
                            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                        }
                    }
                    .onAppear {
                        print("🔄 App: View appeared, ensuring local auth state is ready...")
                        authManager.setupAuthListener()
                        notificationService.requestAuthorization()
                        challengeManager.setModelContext(container.mainContext)
                        challengeManager.setNotificationService(notificationService)
                        challengeManager.checkAllExpirations()
                        achievementService.setModelContext(container.mainContext)
                        achievementService.setNotificationService(notificationService)

                        // Initialize achievements for current user
                        if let userID = authManager.currentUserID {
                            achievementService.initializeAchievements(for: userID)
                        }
                    }
                    .modelContainer(container)
                } else {
                    // Show error recovery view when database fails
                    DatabaseErrorView()
                }
            }
        }
    }
}

// MARK: - Database Error View

struct DatabaseErrorView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.orange)

            Text("Unable to Load Data")
                .font(.title2.bold())

            Text("There was a problem loading your saved data. This might be due to a corrupted database or storage issue.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 12) {
                Button {
                    // Attempt to delete corrupted database and restart
                    deleteDatabaseAndRestart()
                } label: {
                    Label("Reset App Data", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Open Settings")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 32)
        }
        .padding()
    }

    private func deleteDatabaseAndRestart() {
        // Delete the SwiftData store
        let fileManager = FileManager.default
        if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let storeURL = appSupport.appendingPathComponent("default.store")
            try? fileManager.removeItem(at: storeURL)

            // Also remove related files
            let shmURL = appSupport.appendingPathComponent("default.store-shm")
            let walURL = appSupport.appendingPathComponent("default.store-wal")
            try? fileManager.removeItem(at: shmURL)
            try? fileManager.removeItem(at: walURL)
        }

        // Reset onboarding flag
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")

        // Force restart by exiting (user will relaunch)
        exit(0)
    }
}
