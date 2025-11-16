import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var classifierService = WasteClassifierService()
    @State private var tabSelection = 0

    var body: some View {
        VStack {
            TabView(selection: $tabSelection) {
                OnboardingCardView(
                    imageName: "leaf.arrow.circlepath",
                    title: "Welcome to Eco Hero",
                    description: "Join a global community making a positive impact on our planet."
                )
                .tag(0)

                OnboardingCardView(
                    imageName: "camera.viewfinder",
                    title: "Scan & Sort Waste",
                    description: "Use your camera to instantly identify if an item is recyclable or compostable."
                )
                .tag(1)

                OnboardingCardView(
                    imageName: "chart.bar.xaxis",
                    title: "Track Your Impact",
                    description: "Log your daily eco-friendly activities and watch your positive impact grow over time."
                )
                .tag(2)

                OnboardingCardView(
                    imageName: "trophy",
                    title: "Complete Challenges",
                    description: "Take on fun challenges, earn achievements, and compete with friends."
                )
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .padding(.bottom)

            Button(action: handleNextButton) {
                Text(tabSelection == 3 ? "Get Started" : "Next")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
    }

    private func handleNextButton() {
        if tabSelection < 3 {
            withAnimation {
                tabSelection += 1
            }
        } else {
            // Request permission on the last step
            Task {
                await classifierService.requestAuthorization()
                // Regardless of the outcome, complete onboarding so the user sees the main app
                withAnimation {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasCompletedOnboarding: .constant(false))
    }
}
