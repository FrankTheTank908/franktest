import SwiftUI
import SwiftData

@main
struct NetProofApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [NetworkTestRecord.self, ISPPlanProfile.self])
    }
}
