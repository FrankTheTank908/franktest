import Foundation
import PDFKit

struct ProofReportGenerator {
    func generate(record: NetworkTestRecord) -> Data {
        let meta = [kCGPDFContextCreator: "NetProof", kCGPDFContextAuthor: "NetProof"]
        let format = UIGraphicsPDFRendererFormat(); format.documentInfo = meta as [String: Any]
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792), format: format)
        return renderer.pdfData { ctx in
            ctx.beginPage()
            let text = "NetProof ISP Report\nDate: \(record.createdAt)\nScore: \(record.healthScore)\nIssue: \(record.diagnosisSummary)"
            text.draw(in: CGRect(x: 24, y: 24, width: 560, height: 300), withAttributes: [.font: UIFont.systemFont(ofSize: 18)])
        }
    }
}
