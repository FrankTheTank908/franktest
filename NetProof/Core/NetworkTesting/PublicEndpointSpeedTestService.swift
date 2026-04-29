import Foundation

/// Development-only fallback when user has no backend.
/// Uses public HTTP endpoints for rough throughput estimation.
struct PublicEndpointSpeedTestService: NetworkTestService {
    let downloadURL: URL
    let uploadURL: URL
    let session: URLSession = .shared

    func runTest(type: TestType, progress: @escaping (NetworkTestProgress) -> Void) async throws -> TestMetrics {
        progress(.init(phase: "Pinging upload host", metrics: .mock))
        let idle = try await ping(url: uploadURL, count: 6)

        progress(.init(phase: "Downloading test file", metrics: .mock))
        let download = try await measureDownload(from: downloadURL)

        progress(.init(phase: "Generating upload payload", metrics: .mock))
        let samples = try await measureUploads(iterations: type == .quick ? 3 : 6, sizeMB: 6)
        let uploadAvg = samples.reduce(0,+) / Double(samples.count)

        let jitter = max(1, idle * 0.1)
        let packetLoss = 0.0

        return TestMetrics(
            downloadMbps: download,
            uploadMbps: uploadAvg,
            idleLatencyMs: idle,
            downloadLoadedLatencyMs: idle + 12,
            uploadLoadedLatencyMs: idle + max(15, 180 / max(uploadAvg, 1)),
            jitterMs: jitter,
            packetLossPercent: packetLoss,
            uploadMinMbps: samples.min() ?? uploadAvg,
            uploadMaxMbps: samples.max() ?? uploadAvg,
            uploadAvgMbps: uploadAvg,
            uploadConsistencyPercent: consistency(samples)
        )
    }

    private func ping(url: URL, count: Int) async throws -> Double {
        var values: [Double] = []
        for _ in 0..<count {
            var req = URLRequest(url: url)
            req.httpMethod = "HEAD"
            let start = Date()
            _ = try await session.data(for: req)
            values.append(Date().timeIntervalSince(start) * 1000)
        }
        return values.reduce(0,+)/Double(values.count)
    }

    private func measureDownload(from url: URL) async throws -> Double {
        let start = Date()
        let (data, _) = try await session.data(from: url)
        let duration = max(Date().timeIntervalSince(start), 0.001)
        return (Double(data.count) * 8) / duration / 1_000_000
    }

    private func measureUploads(iterations: Int, sizeMB: Int) async throws -> [Double] {
        let payload = Data(repeating: 0xAB, count: sizeMB * 1024 * 1024)
        var values: [Double] = []
        for _ in 0..<iterations {
            var req = URLRequest(url: uploadURL)
            req.httpMethod = "POST"
            req.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            let start = Date()
            _ = try await session.upload(for: req, from: payload)
            let duration = max(Date().timeIntervalSince(start), 0.001)
            values.append((Double(payload.count) * 8) / duration / 1_000_000)
        }
        return values
    }

    private func consistency(_ samples: [Double]) -> Double {
        let avg = samples.reduce(0,+)/Double(samples.count)
        let variance = samples.map { pow($0-avg, 2) }.reduce(0,+)/Double(samples.count)
        return max(0, min(100, 100 - (sqrt(variance)/max(avg, 0.1)*100)))
    }
}
