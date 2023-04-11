//
//  FormattingTests.swift
//  Better StepTests
//
//  Created by Fritz Anderson on 4/11/23.
//

import XCTest
@testable import Walk_Test

private let doubleStringPairs: [(Double, String)] = [
    (0.0, "0.00000"), (-1.0, "-1.00000"), (123.45, "123.45000"),
    (-123.45, "-123.45000")
    ]

final class FormattingTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testForwardFormatting() {
        for (number, formatted) in doubleStringPairs {
            let asFormatted = number.pointFive
            XCTAssertEqual(asFormatted, formatted, "Mismatch in rendering of \(number)")
        }
    }

//    func testCoffectFormat() {
//        for (_, formatted) in doubleStringPairs {
//            var match: Regex.Match? = nil
//            XCTAssertNoThrow(match = try /-?\d+\.\d{5}/.wholeMatch(in: formatted),
//            "Matching for \(formatted) threw")
//            XCTAssertNotNil(match, "No match for \(formatted)")
//        }
//    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
