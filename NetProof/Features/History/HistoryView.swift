import SwiftUI
import SwiftData
import Charts

struct HistoryView: View {
    @Query(sort: \NetworkTestRecord.createdAt, order: .reverse) private var records: [NetworkTestRecord]

    var body: some View {
        List {
            if records.isEmpty { Text("No tests yet.") }
            Chart(records.prefix(20), id: \.id) { r in
                LineMark(x: .value("Time", r.createdAt), y: .value("Score", r.healthScore))
            }.frame(height: 220)
            ForEach(records) { r in
                NavigationLink(destination: ResultsView(record: r)) {
                    VStack(alignment: .leading) {
                        Text(r.createdAt, style: .date)
                        Text("\(r.testType.rawValue) • Score \(r.healthScore)")
                    }
                }
            }
        }.navigationTitle("History")
    }
}
