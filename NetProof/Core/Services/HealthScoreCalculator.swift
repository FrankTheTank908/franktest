import Foundation

struct HealthScoreCalculator {
    func score(for m: TestMetrics) -> Int {
        var score = 100.0
        score -= min(m.idleLatencyMs / 2, 20)
        score -= min(m.jitterMs, 20)
        score -= min(m.packetLossPercent * 15, 25)
        score -= min((m.uploadLoadedLatencyMs - m.idleLatencyMs) / 4, 20)
        score -= m.uploadMbps < 10 ? 10 : 0
        return max(0, min(100, Int(score.rounded())))
    }
}
