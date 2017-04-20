import XCTest
@testable import strings_file_lib

class strings_file_libTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(strings_file_lib().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
