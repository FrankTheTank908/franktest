import Foundation

protocol AIAdviceService {
    func advice(for diagnosis: DiagnosisResult) async throws -> String
}

struct LocalRuleAdviceService: AIAdviceService {
    func advice(for diagnosis: DiagnosisResult) async throws -> String {
        "Recommended actions: \(diagnosis.actions.joined(separator: ", "))."
    }
}

struct RemoteAIAdviceService: AIAdviceService {
    func advice(for diagnosis: DiagnosisResult) async throws -> String {
        // TODO: Connect to paid backend AI advice endpoint.
        throw URLError(.badServerResponse)
    }
}
