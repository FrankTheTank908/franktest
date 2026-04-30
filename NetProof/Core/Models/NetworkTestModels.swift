import Foundation
import SwiftData

enum TestType: String, Codable, CaseIterable {
    case quick
    case uploadDoctor
    case gamingZoom
}

struct TestMetrics: Codable {
    var downloadMbps: Double
    var uploadMbps: Double
    var idleLatencyMs: Double
    var downloadLoadedLatencyMs: Double
    var uploadLoadedLatencyMs: Double
    var jitterMs: Double
    var packetLossPercent: Double
    var uploadMinMbps: Double
    var uploadMaxMbps: Double
    var uploadAvgMbps: Double
    var uploadConsistencyPercent: Double
}

@Model
final class NetworkTestRecord {
    var id: UUID
    var createdAt: Date
    var testTypeRaw: String
    var healthScore: Int
    var diagnosisSummary: String
    var metricsData: Data

    init(id: UUID = UUID(), createdAt: Date = .now, testType: TestType, healthScore: Int, diagnosisSummary: String, metrics: TestMetrics) {
        self.id = id
        self.createdAt = createdAt
        self.testTypeRaw = testType.rawValue
        self.healthScore = healthScore
        self.diagnosisSummary = diagnosisSummary
        self.metricsData = (try? JSONEncoder().encode(metrics)) ?? Data()
    }

    var testType: TestType { TestType(rawValue: testTypeRaw) ?? .quick }
    var metrics: TestMetrics { (try? JSONDecoder().decode(TestMetrics.self, from: metricsData)) ?? .mock }
}

extension TestMetrics {
    static let mock = TestMetrics(downloadMbps: 180, uploadMbps: 12, idleLatencyMs: 18, downloadLoadedLatencyMs: 64, uploadLoadedLatencyMs: 142, jitterMs: 22, packetLossPercent: 1.6, uploadMinMbps: 5, uploadMaxMbps: 14, uploadAvgMbps: 11, uploadConsistencyPercent: 61)
}

@Model
final class ISPPlanProfile {
    var ispName: String
    var advertisedDownloadMbps: Double
    var advertisedUploadMbps: Double

    init(ispName: String = "", advertisedDownloadMbps: Double = 0, advertisedUploadMbps: Double = 0) {
        self.ispName = ispName
        self.advertisedDownloadMbps = advertisedDownloadMbps
        self.advertisedUploadMbps = advertisedUploadMbps
    }
}
