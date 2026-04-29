import SwiftUI
import SwiftData

struct OnboardingView: View {
    let onFinish: () -> Void
    @Environment(\.modelContext) private var context

    @State private var page = 0
    @State private var ispName = ""
    @State private var down = ""
    @State private var up = ""

    var body: some View {
        VStack(spacing: 18) {
            TabView(selection: $page) {
                Text("Welcome to NetProof\nMeasure real internet quality, not just headline speed.")
                    .multilineTextAlignment(.center).tag(0)
                Text("Your data stays on-device in MVP. No account required.")
                    .multilineTextAlignment(.center).tag(1)
                Form {
                    Section("Optional ISP Plan") {
                        TextField("ISP name", text: $ispName)
                        TextField("Advertised download Mbps", text: $down)
                        TextField("Advertised upload Mbps", text: $up)
                    }
                }.tag(2)
            }
            .tabViewStyle(.page)

            Button(page < 2 ? "Next" : "Get Started") {
                if page < 2 { page += 1 }
                else {
                    savePlanIfNeeded()
                    onFinish()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func savePlanIfNeeded() {
        guard !ispName.isEmpty || !down.isEmpty || !up.isEmpty else { return }
        let profile = ISPPlanProfile(
            ispName: ispName,
            advertisedDownloadMbps: Double(down) ?? 0,
            advertisedUploadMbps: Double(up) ?? 0
        )
        context.insert(profile)
        try? context.save()
    }
}
