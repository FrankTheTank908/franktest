import SwiftUI

struct RootView: View {
    @State private var hasOnboarded = false

    var body: some View {
        NavigationStack {
            if hasOnboarded {
                DashboardView()
            } else {
                OnboardingView(onFinish: { hasOnboarded = true })
            }
        }
    }
}
