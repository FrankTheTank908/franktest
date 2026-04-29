import SwiftUI
import SwiftData

@MainActor
final class RunTestViewModel: ObservableObject {
    @Published var phase = "Ready"
    @Published var liveMetrics = TestMetrics.mock
    @Published var isRunning = false
    @Published var selectedType: TestType = .quick

    private let networkService: NetworkTestService
    private let diagnosisEngine: DiagnosisEngine
    private let scorer = HealthScoreCalculator()

    init(diagnosisEngine: DiagnosisEngine = RuleBasedDiagnosisEngine()) {
        self.diagnosisEngine = diagnosisEngine
        if AppConfig.useRealHTTPTests {
            self.networkService = HTTPNetworkTestService(baseURL: AppConfig.backendBaseURL)
        } else {
            self.networkService = MockNetworkTestService()
        }
    }

    func run(context: ModelContext) async {
        isRunning = true
        defer { isRunning = false }
        do {
            let metrics = try await networkService.runTest(type: selectedType) { p in
                Task { @MainActor in self.phase = p.phase; self.liveMetrics = p.metrics }
            }
            let diagnosis = diagnosisEngine.diagnose(metrics: metrics, history: [])
            let score = scorer.score(for: metrics)
            let record = NetworkTestRecord(testType: selectedType, healthScore: score, diagnosisSummary: diagnosis.title, metrics: metrics)
            context.insert(record)
            try? context.save()
            phase = "Completed"
        } catch {
            phase = "Test failed. Check backend URL/network."
        }
    }
}

struct RunTestView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var vm = RunTestViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Run Network Test").font(.title2.bold())
                Picker("Test Type", selection: $vm.selectedType) {
                    Text("Quick").tag(TestType.quick)
                    Text("Upload Doctor").tag(TestType.uploadDoctor)
                    Text("Gaming/Zoom").tag(TestType.gamingZoom)
                }.pickerStyle(.segmented)

                VStack(spacing: 8) {
                    Text(vm.phase).font(.headline)
                    Gauge(value: vm.liveMetrics.uploadMbps, in: 0...200) {
                        Text("Upload")
                    } currentValueLabel: {
                        Text("\(vm.liveMetrics.uploadMbps, specifier: "%.1f") Mbps")
                    }.tint(.mint)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

                HStack {
                    metric("Download", vm.liveMetrics.downloadMbps)
                    metric("Latency", vm.liveMetrics.idleLatencyMs, suffix: "ms")
                }

                Button(vm.isRunning ? "Running..." : "Start Test") {
                    Task { await vm.run(context: context) }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(vm.isRunning)
            }
            .padding()
        }
        .background(LinearGradient(colors: [.blue.opacity(0.2), .black.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    private func metric(_ title: String, _ value: Double, suffix: String = "Mbps") -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text("\(value, specifier: "%.1f") \(suffix)").font(.title3.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}
