import Foundation

struct DiagnosisResult {
    let title: String
    let explanation: String
    let actions: [String]
}

protocol DiagnosisEngine {
    func diagnose(metrics: TestMetrics, history: [NetworkTestRecord]) -> DiagnosisResult
}

struct RuleBasedDiagnosisEngine: DiagnosisEngine {
    func diagnose(metrics: TestMetrics, history: [NetworkTestRecord]) -> DiagnosisResult {
        if metrics.idleLatencyMs < 40 && metrics.uploadLoadedLatencyMs > 120 {
            return DiagnosisResult(
                title: "Likely upload bufferbloat",
                explanation: "Your normal ping is fine, but latency spikes during upload. This usually means upload saturation or router queueing.",
                actions: ["Limit background cloud backups", "Enable SQM/QoS on router", "Ask ISP about upstream congestion"]
            )
        }
        if metrics.downloadMbps > 100 && metrics.uploadMbps < 15 {
            return DiagnosisResult(
                title: "Upload bottleneck",
                explanation: "Download is healthy but upload is consistently weak compared with modern work-from-home needs.",
                actions: ["Check ISP plan upload tier", "Test via Ethernet", "Ask ISP for upstream profile check"]
            )
        }
        if metrics.jitterMs > 20 || metrics.packetLossPercent > 1 {
            return DiagnosisResult(
                title: "Stability issue",
                explanation: "Jitter or packet loss is high, so calls and gaming may feel inconsistent.",
                actions: ["Reboot modem/router", "Test off-peak hours", "Share report with ISP support"]
            )
        }
        return DiagnosisResult(
            title: "Connection looks healthy",
            explanation: "Your metrics are generally stable for video calls, gaming, and uploads.",
            actions: ["Keep periodic checks", "Save report for baseline tracking"]
        )
    }
}
