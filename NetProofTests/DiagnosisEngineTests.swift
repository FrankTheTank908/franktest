import XCTest
@testable import NetProof

final class DiagnosisEngineTests: XCTestCase {
    func testDetectsUploadBufferbloat() {
        let engine = RuleBasedDiagnosisEngine()
        let metrics = TestMetrics(downloadMbps: 200, uploadMbps: 20, idleLatencyMs: 15, downloadLoadedLatencyMs: 40, uploadLoadedLatencyMs: 180, jitterMs: 5, packetLossPercent: 0, uploadMinMbps: 10, uploadMaxMbps: 25, uploadAvgMbps: 20, uploadConsistencyPercent: 70)
        let result = engine.diagnose(metrics: metrics, history: [], plan: nil)
        XCTAssertEqual(result.title, "Likely upload bufferbloat")
    }

    func testDetectsPoorUploadVersusPlan() {
        let engine = RuleBasedDiagnosisEngine()
        let metrics = TestMetrics(downloadMbps: 300, uploadMbps: 12, idleLatencyMs: 18, downloadLoadedLatencyMs: 35, uploadLoadedLatencyMs: 50, jitterMs: 4, packetLossPercent: 0, uploadMinMbps: 10, uploadMaxMbps: 14, uploadAvgMbps: 12, uploadConsistencyPercent: 88)
        let plan = ISPPlanProfile(ispName: "Test ISP", advertisedDownloadMbps: 300, advertisedUploadMbps: 50)
        let result = engine.diagnose(metrics: metrics, history: [], plan: plan)
        XCTAssertEqual(result.title, "Below promised upload speed")
    }
}
