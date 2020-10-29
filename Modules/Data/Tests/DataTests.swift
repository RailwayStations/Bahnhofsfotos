import XCTest
@testable import Data

final class DataTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Data().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
