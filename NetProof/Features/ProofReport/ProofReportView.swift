import SwiftUI

struct ProofReportView: View {
    let record: NetworkTestRecord?
    @State private var status = ""
    private let generator = ProofReportGenerator()

    var body: some View {
        VStack(spacing: 12) {
            Text("Proof Report")
            Button("Export PDF") {
                guard let record else { status = "No test available"; return }
                let data = generator.generate(record: record)
                status = "Generated PDF (\(data.count) bytes)."
                // TODO: present share sheet with generated file URL.
            }
            Text(status).font(.footnote).foregroundStyle(.secondary)
        }.padding()
    }
}
