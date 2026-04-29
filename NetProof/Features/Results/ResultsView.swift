import SwiftUI
import SwiftData

struct ResultsView: View {
    let record: NetworkTestRecord
    @Query private var plans: [ISPPlanProfile]

    var body: some View {
        let plan = plans.first
        List {
            Section("Summary") {
                Text("Score: \(record.healthScore)/100")
                Text("Diagnosis: \(record.diagnosisSummary)")
            }

            Section("Performance") {
                Text("Download: \(record.metrics.downloadMbps, specifier: "%.1f") Mbps")
                Text("Upload: \(record.metrics.uploadMbps, specifier: "%.1f") Mbps")
                Text("Latency: \(record.metrics.idleLatencyMs, specifier: "%.0f") ms")
                Text("Jitter: \(record.metrics.jitterMs, specifier: "%.1f") ms")
                Text("Packet loss: \(record.metrics.packetLossPercent, specifier: "%.1f")%")
            }

            if let plan {
                Section("ISP Plan Comparison") {
                    Text("ISP: \(plan.ispName.isEmpty ? "Not set" : plan.ispName)")
                    if plan.advertisedDownloadMbps > 0 {
                        let downPct = (record.metrics.downloadMbps / plan.advertisedDownloadMbps) * 100
                        Text("You are getting \(Int(downPct.rounded()))% of your promised download speed.")
                    }
                    if plan.advertisedUploadMbps > 0 {
                        let upPct = (record.metrics.uploadMbps / plan.advertisedUploadMbps) * 100
                        Text("You are getting \(Int(upPct.rounded()))% of your promised upload speed.")
                    }
                }
            }
        }
        .navigationTitle("Results")
    }
}
