import SwiftUI
import SwiftData

struct DashboardView: View {
    @State private var showRunTest = false
    @Query(sort: \NetworkTestRecord.createdAt, order: .reverse) private var records: [NetworkTestRecord]

    var body: some View {
        List {
            Section("Internet Health") {
                Text("Score: \(records.first?.healthScore ?? 0)/100").font(.title2).bold()
                Text(records.first?.diagnosisSummary ?? "Run your first test")
            }
            Button("Run Test") { showRunTest = true }
            NavigationLink("History", destination: HistoryView())
            NavigationLink("Generate Proof Report", destination: ProofReportView(record: records.first))
        }
        .navigationTitle("NetProof")
        .sheet(isPresented: $showRunTest) { RunTestView() }
    }
}
