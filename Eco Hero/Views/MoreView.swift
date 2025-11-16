//
//  MoreView.swift
//  Eco Hero
//
//  Created by Rishabh Bansal on 11/18/25.
//

import SwiftUI

struct MoreView: View {
    var body: some View {
        LearnView(embedInNavigation: true)
    }
}

#Preview {
    MoreView()
        .environment(AuthenticationManager())
        .environment(CloudSyncService())
        .environment(TipModelService())
        .environment(WasteClassifierService())
}
