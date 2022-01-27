//
//  DASIResponseTests.swift
//  Better StepTests
//
//  Created by Fritz Anderson on 1/27/22.
//

import XCTest
import Algorithms
@testable import Better_Step

class DASIResponseTests: XCTestCase {
    var responses: [DASIResponse] = []
    static let responseCount = 12
    static let allQIDs = (QuestionID(1)...QuestionID(responseCount))

    override func setUpWithError() throws {
        responses = Self.allQIDs
            .map { DASIResponse(id: $0) }
        let oneThird = Self.responseCount/3
        var counter = 0
        for index in (counter..<oneThird) {
            responses[index] = responses[index].withResponse(.yes)
        }
        counter += oneThird
        for index in (counter..<(counter+oneThird)) {
            responses[index] = responses[index].withResponse(.no)
        }
        // and the rest is .unknown.
    }

    func expectedAnswerAt(_ qid: QuestionID) -> AnswerState? {
        guard (0..<responses.count)
                .contains(qid.index) else {
                    return nil
                }
        return responses[qid.index]
            .response
    }

    func partsByAnswer() -> (yes    : Set<DASIResponse>,
                             no     : Set<DASIResponse>,
                             unknown: Set<DASIResponse>) {
        var yesSet    : Set<DASIResponse> = []
        var noSet     : Set<DASIResponse> = []
        var unknownSet: Set<DASIResponse> = []

        for element in responses {
            switch element.response {
            case .yes: yesSet    .insert(element)
            case .no : noSet     .insert(element)
            default  : unknownSet.insert(element)
            }
        }

        return (yes: yesSet, no: noSet, unknown: unknownSet)
    }

    func testIndexing() {
        let (y, n, u) = partsByAnswer()
        XCTAssertEqual(y.count, n.count, "Initialization and count of initial (equal) response sets")
        XCTAssertEqual(y.count + n.count + u.count, responses.count,
        "Partition by Answer should be comprehensive")
    }

    func testSubstitution() {
        for (n, element) in responses.enumerated() {
            let previousValue = element

            responses[n] = element.withResponse(.no)

            XCTAssertEqual(responses[n].id, previousValue.id,
            "Resetting response value should not affect ID")
            XCTAssert(responses[n].timestamp > previousValue.timestamp, "changing a DASIResponse's choice should advance its timestamp.")

        }
        let (y, n, u) = partsByAnswer()
        XCTAssertEqual(y.count, 0, "Setting all to .no should empty .yes")
        XCTAssertEqual(u.count, 0, "Setting all to .no should empty .unknown")
        XCTAssertEqual(n.count, responses.count,
                       "Setting all elements to .no should capture the whole series")
    }

    func testOrdering() {
        var toBeSorted = responses
        toBeSorted.shuffle()

        let pairCollection = toBeSorted.sorted()
            .adjacentPairs()

        let seemsSorted =
        pairCollection
            .allSatisfy { (left, right) -> Bool in
                return left.id < right.id
            }
        XCTAssert(seemsSorted, "Sorting DASIResponse by id should work; check the < operator.")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}
