import SwiftUI
import SwiftData

@MainActor
final class RunTestViewModel: ObservableObject {
    @Published var phase = "Ready"
    @Published var liveMetrics = TestMetrics.mock
    @Published var isRunning = false

    private let networkService: NetworkTestService
    private let diagnosisEngine: DiagnosisEngine
    private let scorer = HealthScoreCalculator()

    init(networkService: NetworkTestService = MockNetworkTestService(), diagnosisEngine: DiagnosisEngine = RuleBasedDiagnosisEngine()) {
        self.networkService = networkService
        self.diagnosisEngine = diagnosisEngine
    }

    func run(testType: TestType, context: ModelContext, history: [NetworkTestRecord], plan: ISPPlanProfile?) async {
        isRunning = true
        defer { isRunning = false }
        do {
            let metrics = try await networkService.runTest(type: testType) { p in
                Task { @MainActor in self.phase = p.phase; self.liveMetrics = p.metrics }
            }
            let diagnosis = diagnosisEngine.diagnose(metrics: metrics, history: history, plan: plan)
            let score = scorer.score(for: metrics)
            let record = NetworkTestRecord(testType: testType, healthScore: score, diagnosisSummary: diagnosis.title, metrics: metrics)
            context.insert(record)
            try? context.save()
            phase = "Done"
        } catch {
            phase = "Test failed"
        }
    }
}

struct RunTestView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \NetworkTestRecord.createdAt, order: .reverse) private var history: [NetworkTestRecord]
    @Query private var plans: [ISPPlanProfile]
    @StateObject private var vm = RunTestViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text(vm.phase).font(.headline)
            Text("Live upload: \(vm.liveMetrics.uploadMbps, specifier: "%.1f") Mbps")
            HStack {
                runButton("Quick Test", type: .quick)
                runButton("Upload Doctor", type: .uploadDoctor)
                runButton("Gaming/Zoom", type: .gamingZoom)
            }
        }.padding()
    }

    private func runButton(_ title: String, type: TestType) -> some View {
        Button(vm.isRunning ? "Running..." : title) {
            Task { await vm.run(testType: type, context: context, history: history, plan: plans.first) }
        }
        .disabled(vm.isRunning)
        .buttonStyle(.borderedProminent)
    }
}
