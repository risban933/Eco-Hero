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

    var sharedModelContainer: ModelContainer = {
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
            print("❌ App: FATAL ERROR - Could not create ModelContainer")
            print("❌ App: Error: \(error)")
            print("❌ App: Error details: \(error.localizedDescription)")

            if let nsError = error as NSError? {
                print("❌ App: Error domain: \(nsError.domain)")
                print("❌ App: Error code: \(nsError.code)")
                print("❌ App: Error userInfo: \(nsError.userInfo)")
            }

            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasCompletedOnboarding {
                    if authManager.isAuthenticated {
                        MainTabView()
                            .environment(authManager)
                            .environment(syncService)
                            .environment(tipService)
                            .environment(wasteClassifier)
                            .environment(foundationContentService)
                    } else {
                        AuthenticationView()
                            .environment(authManager)
                            .environment(syncService)
                            .environment(tipService)
                            .environment(wasteClassifier)
                            .environment(foundationContentService)
                    }
                } else {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                }
            }
            .onAppear {
                print("🔄 App: View appeared, ensuring local auth state is ready...")
                authManager.setupAuthListener()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
