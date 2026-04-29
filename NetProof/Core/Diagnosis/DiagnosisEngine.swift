import Foundation

struct DiagnosisResult {
    let title: String
    let explanation: String
    let actions: [String]
}

protocol DiagnosisEngine {
    func diagnose(metrics: TestMetrics, history: [NetworkTestRecord], plan: ISPPlanProfile?) -> DiagnosisResult
}

struct RuleBasedDiagnosisEngine: DiagnosisEngine {
    func diagnose(metrics: TestMetrics, history: [NetworkTestRecord], plan: ISPPlanProfile?) -> DiagnosisResult {
        if metrics.idleLatencyMs < 40 && metrics.uploadLoadedLatencyMs > 120 {
            return DiagnosisResult(
                title: "Likely upload bufferbloat",
                explanation: "Your normal ping is good, but it spikes badly while uploading. This usually means your upload link is getting saturated.",
                actions: ["Pause cloud backups during calls", "Enable SQM/QoS on your router", "Ask your ISP to check upstream congestion"]
            )
        }

        if metrics.downloadMbps > 100 && metrics.uploadMbps < 15 {
            return DiagnosisResult(
                title: "Upload bottleneck",
                explanation: "Your download speed is strong, but upload stays low. That can hurt Zoom quality, backups, and sending files.",
                actions: ["Test with Ethernet", "Check your plan's upload cap", "Ask ISP for an upstream profile check"]
            )
        }

        if metrics.jitterMs > 20 || metrics.packetLossPercent > 1 {
            return DiagnosisResult(
                title: "Unstable connection",
                explanation: "Jitter or packet loss is elevated across this test, so calls and gaming may feel inconsistent.",
                actions: ["Reboot modem and router", "Retest at a different time", "Share proof report with ISP support"]
            )
        }

        if hasTimeOfDayVariance(history: history) {
            return DiagnosisResult(
                title: "Possible peak-hour congestion",
                explanation: "Your results change a lot depending on time of day, which often points to neighborhood or ISP congestion.",
                actions: ["Run tests morning and evening for 3 days", "Use the report timeline as evidence", "Ask ISP about local node congestion"]
            )
        }

        if let plan, plan.advertisedUploadMbps > 0 {
            let pct = (metrics.uploadMbps / plan.advertisedUploadMbps) * 100
            if pct < 50 {
                return DiagnosisResult(
                    title: "Below promised upload speed",
                    explanation: "You are getting only \(Int(pct.rounded()))% of your advertised upload speed right now.",
                    actions: ["Run 2-3 Ethernet tests", "Save proof report", "Contact ISP with the measured percentage"]
                )
            }
        }

        return DiagnosisResult(
            title: "Connection looks healthy",
            explanation: "Your metrics look stable overall for calls, gaming, and daily use.",
            actions: ["Keep periodic checks", "Save this run as your baseline"]
        )
    }

    private func hasTimeOfDayVariance(history: [NetworkTestRecord]) -> Bool {
        guard history.count >= 4 else { return false }
        let uploads = history.map { $0.metrics.uploadMbps }
        guard let minVal = uploads.min(), let maxVal = uploads.max(), minVal > 0 else { return false }
        return (maxVal / minVal) > 2.0
    }
}
