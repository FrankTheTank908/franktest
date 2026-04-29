import SwiftUI

struct ResultsView: View {
    let record: NetworkTestRecord
    var body: some View {
        List {
            Text("Score: \(record.healthScore)")
            Text("Diagnosis: \(record.diagnosisSummary)")
            Text("Upload: \(record.metrics.uploadMbps, specifier: "%.1f") Mbps")
        }.navigationTitle("Results")
    }
}
