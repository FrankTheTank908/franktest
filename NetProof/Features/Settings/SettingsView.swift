import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section("Plan") { Text("ISP details") }
            Section("Privacy") { Text("No user account required") }
            Section("Purchases") { Text("Manage purchases / restore") }
        }.navigationTitle("Settings")
    }
}
