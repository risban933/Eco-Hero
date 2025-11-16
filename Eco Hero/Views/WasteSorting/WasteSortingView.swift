//
//  WasteSortingView.swift
//  Eco Hero
//
//  Created by Rishabh Bansal on 11/15/25.
//

import SwiftUI
import SwiftData

struct WasteSortingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(WasteClassifierService.self) private var classifier
    @Environment(AuthenticationManager.self) private var authManager
    @Query(sort: [SortDescriptor(\WasteSortingResult.timestamp, order: .reverse)], animation: .snappy)
    private var recentResults: [WasteSortingResult]

    @State private var score: Int = 0
    @State private var streak: Int = 0
    @State private var feedbackText: String?
    @State private var showPermissionAlert = false

    private let impactGenerator = UINotificationFeedbackGenerator()

    var body: some View {
        VStack(spacing: 20) {
            ZStack(alignment: .topLeading) {
                CameraPreviewView(session: classifier.session)
                    .frame(maxWidth: .infinity, maxHeight: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(radius: 8)

                predictionOverlay
            }
            .padding(.horizontal)

            scorePanel

            if let feedbackText {
                Text(feedbackText)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGreen).opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
            }

            binButtons
                .padding(.horizontal)

            recentHistory
        }
        .padding(.vertical)
        .navigationTitle("Vision Sorter")
        .alert("Camera Access Needed", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enable camera access in Settings to play the sorting game.")
        }
        .onAppear {
            Task { await handleAuthorization() }
        }
        .onDisappear {
            classifier.stopSession()
        }
    }

    private var predictionOverlay: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Detected", systemImage: "camera.viewfinder")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(classifier.predictedBin.rawValue)
                .font(.title2.bold())

            Text("Confidence \(Int(classifier.confidence * 100))%")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
    }

    private var scorePanel: some View {
        HStack(spacing: 16) {
            VStack {
                Text("Score")
                    .font(.headline)
                Text("\(score)")
                    .font(.system(size: 32, weight: .bold))
            }
            .frame(maxWidth: .infinity)

            VStack {
                Text("Streak")
                    .font(.headline)
                Text("\(streak)")
                    .font(.system(size: 32, weight: .bold))
            }
            .frame(maxWidth: .infinity)

            VStack {
                Text("Accuracy")
                    .font(.headline)
                Text("\(accuracyString)%")
                    .font(.system(size: 32, weight: .bold))
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }

    private var binButtons: some View {
        HStack(spacing: 16) {
            ForEach(WasteBin.allCases, id: \.self) { bin in
                Button {
                    evaluateSelection(bin)
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: bin.icon)
                            .font(.title)
                        Text(bin.rawValue)
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .background(bin.color)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }

    private var recentHistory: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Rounds")
                .font(.headline)
                .padding(.horizontal)

            ForEach(recentResults.prefix(5)) { result in
                HStack {
                    Image(systemName: result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(result.isCorrect ? Color.green : Color.red)
                    VStack(alignment: .leading) {
                        Text("Predicted \(result.predictedBin.rawValue)")
                            .font(.subheadline.bold())
                        Text("You chose \(result.userSelection.rawValue)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(result.pointsAwarded > 0 ? "+" : "")\(result.pointsAwarded)")
                        .font(.headline)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }

    private func evaluateSelection(_ bin: WasteBin) {
        let predicted = classifier.predictedBin
        let correct = predicted == bin
        let points = correct ? 10 : -5

        score += points
        streak = correct ? streak + 1 : 0
        feedbackText = correct ? "Great job! That belongs in \(bin.rawValue)." : "Try again! This item should go to \(predicted.rawValue)."
        impactGenerator.notificationOccurred(correct ? .success : .error)

        let result = WasteSortingResult(predictedBin: predicted,
                                        userSelection: bin,
                                        isCorrect: correct,
                                        confidence: classifier.confidence,
                                        pointsAwarded: points)
        modelContext.insert(result)
        try? modelContext.save()
    }

    private var accuracyString: String {
        let total = recentResults.count
        let correct = recentResults.filter { $0.isCorrect }.count
        guard total > 0 else { return "0" }
        return String(Int((Double(correct) / Double(total)) * 100))
    }

    private func handleAuthorization() async {
        if classifier.authorizationState == .unknown {
            await classifier.requestAuthorization()
        }

        await MainActor.run {
            switch classifier.authorizationState {
            case .allowed:
                classifier.startSession()
            case .denied:
                showPermissionAlert = true
            case .unknown:
                break
            }
        }
    }
}

#Preview {
    WasteSortingView()
        .environment(AuthenticationManager())
        .environment(WasteClassifierService())
        .modelContainer(for: WasteSortingResult.self, inMemory: true)
}
