import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    var body: some View {
        VStack(spacing: 18) {
            Text("Welcome to NetProof").font(.largeTitle).bold()
            Text("Diagnose unstable internet and create ISP-ready proof reports.").multilineTextAlignment(.center)
            Text("Privacy: no account required, no data sale.").font(.subheadline).foregroundStyle(.secondary)
            Button("Get Started", action: onFinish).buttonStyle(.borderedProminent)
        }.padding()
    }
}
