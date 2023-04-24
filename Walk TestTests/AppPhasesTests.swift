//
//  AppPhasesTests.swift
//  Walk TestTests
//
//  Created by Fritz Anderson on 4/24/23.
//

import XCTest
@testable import Walk_Test

final class AppPhasesTests: XCTestCase {
    override func setUpWithError() throws {
    }
    override func tearDownWithError() throws {
    }

    /// Iterate through the phases, verifying they match the proper sequence.
    /// - parameter sequence: The expected sequence of ``AppPhases``
    /// - parameter commonName: Visible text to identify which sequence is being tested.
    func commonSequence(_ sequence: [AppPhases], commonName: String,
                           file: String = #fileID, line: Int = #line) throws {
        var currentPhase: AppPhases  = .entry
        var expectedSequence = sequence

        repeat {
            let expected = expectedSequence.removeFirst()
            let equality = currentPhase == expected
            XCTAssert(equality, "case “\(currentPhase)” in “\(commonName), advance")
            if !equality {
                throw XCTSkip("Terminating \(commonName) loop")
            }
            currentPhase = currentPhase.next
            if currentPhase == .conclusion {
                ASKeys.isFirstRunComplete = true
            }
        }  while !expectedSequence.isEmpty
    }

    // MARK: - initial runs
    static let initialSequence: [AppPhases] = [
        .entry, .onboarding, .walking, .dasi, .usability, .conclusion, .entry, .greeting
    ]

    func testFromInitial() throws {
        ASKeys.isFirstRunComplete = false
        try commonSequence(Self.initialSequence, commonName: "Initial Run")
    }

    // MARK: - subsequent runs
    static let laterSequence: [AppPhases] = [
        .entry, .greeting, .walking, .conclusion, .entry, .greeting
    ]
    func testFromLater() throws {
        ASKeys.isFirstRunComplete = true
        try commonSequence(Self.laterSequence, commonName: "Following Run")
    }
}
