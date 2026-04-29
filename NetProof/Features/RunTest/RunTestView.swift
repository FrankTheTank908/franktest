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

    func run(testType: TestType, context: ModelContext) async {
        isRunning = true
        defer { isRunning = false }
        do {
            let metrics = try await networkService.runTest(type: testType) { p in
                Task { @MainActor in self.phase = p.phase; self.liveMetrics = p.metrics }
            }
            let diagnosis = diagnosisEngine.diagnose(metrics: metrics, history: [])
            let score = scorer.score(for: metrics)
            let record = NetworkTestRecord(testType: testType, healthScore: score, diagnosisSummary: diagnosis.title, metrics: metrics)
            context.insert(record)
            try? context.save()
        } catch {
            phase = "Test failed"
        }
    }
}

struct RunTestView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var vm = RunTestViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text(vm.phase).font(.headline)
            Text("Upload: \(vm.liveMetrics.uploadMbps, specifier: "%.1f") Mbps")
            Button(vm.isRunning ? "Running..." : "Run Quick Test") {
                Task { await vm.run(testType: .quick, context: context) }
            }.disabled(vm.isRunning)
        }.padding()
    }
}
