import XCTest
@testable import NetProof

final class HealthScoreCalculatorTests: XCTestCase {
    func testScoreRange() {
        let s = HealthScoreCalculator().score(for: .mock)
        XCTAssertTrue((0...100).contains(s))
    }
}
