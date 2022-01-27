//
//  QuestionIDTests.swift
//  Better StepUITests
//
//  Created by Fritz Anderson on 1/25/22.
//

import XCTest
@testable import Better_Step

class QuestionIDTests: XCTestCase {
    let itemCount = 12
    let rawInput_expected = [
        (-1, -1, false), (0, 0, false), (1,1, true), (20, 20, false)
    ]

    // Offset raw values for test `QuestionID`s
    lazy var distances: [Int] = {
        return [-(+itemCount + 1),
                 -itemCount,
                 -1, 0, 1,
                 itemCount,
                 itemCount+1]
    }()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testInitialization () {
        for (input, expect, _) in rawInput_expected {
            let sample = QuestionID(input)
            XCTAssertEqual(sample.rawValue,
                           expect, "rawValue from ID")
        }

        for (input, expectMinus1, _) in rawInput_expected {
            let sample = QuestionID(index: input)
            XCTAssertEqual(sample.rawValue,
                           expectMinus1+1,
                           "rawValue from index")
        }
    }

    func testValidity() {
        QuestionID.questionCount = itemCount

        for (input, _, shouldBeValid) in rawInput_expected {
            let sample = QuestionID(input)
            XCTAssertEqual(sample.isValid, shouldBeValid, "Validity from rawValue")
        }
    }

    func testDistance() {
        let lhs = QuestionID(1)
        for n in distances {
            let sample = QuestionID(n)
            let epectedDistance =  n - 1
            let compDistance = lhs.distance(to: sample)
            XCTAssertEqual(compDistance, epectedDistance)
        }
    }

    func testIncrement() {
        // Take distance[n] as the raw value
        // Add 1.
        // Turn into a QuestionID()
        // expected is

        let toBeIncremented: [QuestionID] =
        distances
            .map { QuestionID($0) }

        let blindlyIncremented: [QuestionID] =
        distances
            .map { QuestionID($0 + 1)
            }
        let expectedIncremented: [QuestionID?] = blindlyIncremented
            .map { qid in
                let okay = (1...itemCount)
                    .contains(qid.rawValue)
                return okay ? qid : nil
            }
        for (subject, expected) in zip(toBeIncremented, expectedIncremented) {
            let nudged = subject.succ
            XCTAssertEqual(nudged, expected,
                           "succ vs hand-made")
        }
    }

    func testDecrement() {
        let toBeDecremented: [QuestionID] =
        distances
            .map { QuestionID($0) }

        let blindlyDecremented: [QuestionID] =
        distances
            .map { QuestionID($0 + 1)
            }
        let expecteDecremented: [QuestionID?] = blindlyDecremented
            .map { qid in
                let okay = (1...itemCount)
                    .contains(qid.rawValue)
                return okay ? qid : nil
            }
        for (subject, expected) in zip(toBeDecremented, expecteDecremented) {
            let nudged = subject.pred
            XCTAssertEqual(nudged, expected,
                           "pred vs hand-made")
        }
    }

    func testQIDLoop() {
        var loopCount = 0
        let range = QuestionID(1) ... QuestionID(itemCount)
        for qid in range {
            XCTAssert(qid.isValid, "at raw value \(qid.rawValue) - loop should generate correct QueueIDs")
            loopCount += 1
        }
        XCTAssertEqual(loopCount, itemCount,
        "Loop should produce every element")
    }
}
