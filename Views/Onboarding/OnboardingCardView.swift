import SwiftUI

struct OnboardingCardView: View {
    let imageName: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor)
                .padding(.top, 40)

            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

struct OnboardingCardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingCardView(
            imageName: "leaf.arrow.circlepath",
            title: "Welcome to Eco Hero",
            description: "Join a global community making a positive impact on our planet."
        )
    }
}
