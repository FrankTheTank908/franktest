import Foundation

struct SamplePoint: Codable {
    let timestamp: Date
    let bytesTransferred: Int
}

struct SpeedComputation {
    let avgMbps: Double
    let p50Mbps: Double
    let p90Mbps: Double
    let minMbps: Double
    let maxMbps: Double
    let stabilityPercent: Double
}

struct SpeedMeasurementEngine {
    /// Converts cumulative transfer samples into interval Mbps and returns robust aggregates.
    func compute(from samples: [SamplePoint]) -> SpeedComputation {
        guard samples.count >= 2 else {
            return .init(avgMbps: 0, p50Mbps: 0, p90Mbps: 0, minMbps: 0, maxMbps: 0, stabilityPercent: 0)
        }

        var intervalMbps: [Double] = []
        for i in 1..<samples.count {
            let dt = samples[i].timestamp.timeIntervalSince(samples[i-1].timestamp)
            let dBytes = samples[i].bytesTransferred - samples[i-1].bytesTransferred
            guard dt > 0, dBytes >= 0 else { continue }
            intervalMbps.append((Double(dBytes) * 8) / dt / 1_000_000)
        }

        guard !intervalMbps.isEmpty else {
            return .init(avgMbps: 0, p50Mbps: 0, p90Mbps: 0, minMbps: 0, maxMbps: 0, stabilityPercent: 0)
        }

        let sorted = intervalMbps.sorted()
        let avg = intervalMbps.reduce(0,+) / Double(intervalMbps.count)
        let p50 = percentile(sorted, 0.50)
        let p90 = percentile(sorted, 0.90)
        let minV = sorted.first ?? 0
        let maxV = sorted.last ?? 0

        let variance = intervalMbps.map { pow($0 - avg, 2) }.reduce(0,+) / Double(intervalMbps.count)
        let cv = sqrt(variance) / max(avg, 0.1)
        let stability = max(0, min(100, 100 - cv * 100))

        return .init(avgMbps: avg, p50Mbps: p50, p90Mbps: p90, minMbps: minV, maxMbps: maxV, stabilityPercent: stability)
    }

    func jitterMs(_ latencySamplesMs: [Double]) -> Double {
        guard latencySamplesMs.count > 1 else { return 0 }
        var diffs: [Double] = []
        for i in 1..<latencySamplesMs.count {
            diffs.append(abs(latencySamplesMs[i] - latencySamplesMs[i-1]))
        }
        return diffs.reduce(0,+) / Double(diffs.count)
    }

    func packetLossPercent(successes: Int, attempts: Int) -> Double {
        guard attempts > 0 else { return 0 }
        return max(0, min(100, (Double(attempts - successes) / Double(attempts)) * 100))
    }

    private func percentile(_ sorted: [Double], _ p: Double) -> Double {
        let idx = Int((Double(sorted.count - 1) * p).rounded())
        return sorted[max(0, min(sorted.count - 1, idx))]
    }
}
