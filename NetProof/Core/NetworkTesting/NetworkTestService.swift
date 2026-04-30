import Foundation

struct NetworkTestProgress {
    let phase: String
    let metrics: TestMetrics
}

protocol NetworkTestService {
    func runTest(type: TestType, progress: @escaping (NetworkTestProgress) -> Void) async throws -> TestMetrics
}

struct MockNetworkTestService: NetworkTestService {
    func runTest(type: TestType, progress: @escaping (NetworkTestProgress) -> Void) async throws -> TestMetrics {
        var m = TestMetrics.mock
        for phase in ["Pinging", "Measuring Download", "Measuring Upload", "Analyzing Stability"] {
            try await Task.sleep(for: .milliseconds(450))
            m.jitterMs += Double.random(in: -1...1)
            progress(.init(phase: phase, metrics: m))
        }
        return m
    }
}
