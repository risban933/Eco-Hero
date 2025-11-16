//
//  MoreView.swift
//  Eco Hero
//
//  Created by Rishabh Bansal on 11/18/25.
//

import SwiftUI

struct MoreView: View {
    @State private var selectedSection: MoreSection = .learn

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedSection) {
                LearnView(embedInNavigation: false)
                    .tag(MoreSection.learn)

                ProfileView(embedInNavigation: false)
                    .tag(MoreSection.profile)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.25), value: selectedSection)
            .safeAreaInset(edge: .top) {
                Picker("Section", selection: $selectedSection) {
                    ForEach(MoreSection.allCases) { section in
                        Label(section.title, systemImage: section.icon)
                            .tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 12)
            }
            .navigationTitle("More")
        }
    }
}

enum MoreSection: String, CaseIterable, Identifiable {
    case learn
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .learn: return "Learn"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .learn: return "book.fill"
        case .profile: return "person.circle.fill"
        }
    }
}

#Preview {
    MoreView()
        .environment(AuthenticationManager())
        .environment(CloudSyncService())
        .environment(TipModelService())
        .environment(WasteClassifierService())
}
