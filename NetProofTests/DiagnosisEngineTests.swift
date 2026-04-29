import XCTest
@testable import NetProof

final class DiagnosisEngineTests: XCTestCase {
    func testDetectsUploadBufferbloat() {
        let engine = RuleBasedDiagnosisEngine()
        let metrics = TestMetrics(downloadMbps: 200, uploadMbps: 20, idleLatencyMs: 15, downloadLoadedLatencyMs: 40, uploadLoadedLatencyMs: 180, jitterMs: 5, packetLossPercent: 0, uploadMinMbps: 10, uploadMaxMbps: 25, uploadAvgMbps: 20, uploadConsistencyPercent: 70)
        let result = engine.diagnose(metrics: metrics, history: [])
        XCTAssertEqual(result.title, "Likely upload bufferbloat")
    }
}
