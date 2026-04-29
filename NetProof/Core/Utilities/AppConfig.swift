import Foundation

enum TestProvider {
    case netProofBackend
    case publicFallback
    case mock
}

enum AppConfig {
    static let provider: TestProvider = .publicFallback
    static let backendBaseURL = URL(string: "http://localhost:8080")!

    // Public fallback endpoints (development only, best-effort reliability)
    static let publicDownloadURL = URL(string: "https://speed.cloudflare.com/__down?bytes=25000000")!
    static let publicUploadURL = URL(string: "https://httpbin.org/post")!
}
