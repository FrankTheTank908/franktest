import SwiftUI
import SwiftData

struct DashboardView: View {
    @State private var showRunTest = false
    @Query(sort: \NetworkTestRecord.createdAt, order: .reverse) private var records: [NetworkTestRecord]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Internet Health Score").font(.headline)
                    Text("\(records.first?.healthScore ?? 0)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                    Text(records.first?.diagnosisSummary ?? "Run your first real test")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))

                HStack {
                    metricCard("Download", records.first?.metrics.downloadMbps ?? 0)
                    metricCard("Upload", records.first?.metrics.uploadMbps ?? 0)
                }
                HStack {
                    metricCard("Latency", records.first?.metrics.idleLatencyMs ?? 0, suffix: "ms")
                    metricCard("Jitter", records.first?.metrics.jitterMs ?? 0, suffix: "ms")
                }

                Button("Run Test") { showRunTest = true }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                NavigationLink("History & Trends", destination: HistoryView())
                NavigationLink("Generate Proof Report", destination: ProofReportView(record: records.first))
                NavigationLink("Settings", destination: SettingsView())
            }
            .padding()
        }
        .background(LinearGradient(colors: [.indigo.opacity(0.25), .black.opacity(0.15)], startPoint: .top, endPoint: .bottom))
        .navigationTitle("NetProof")
        .sheet(isPresented: $showRunTest) { RunTestView() }
    }

    private func metricCard(_ title: String, _ value: Double, suffix: String = "Mbps") -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text("\(value, specifier: "%.1f") \(suffix)").font(.title3.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}
