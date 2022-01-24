//
//  AccelerometerItemTests.swift
//  Better StepTests
//
//  Created by Fritz Anderson on 1/18/22.
//

import XCTest
import CoreMotion
@testable import Better_Step

class BinaryFormatTests: XCTestCase {
    func testPointThree() {
        let expected = [
            "10000.000", "10000.000", "10000.001",
               "-1.000",    "-1.000", "-1.001",
            ]
        let doubleChallenges:[Double] = [
            10_000, 10_000.0004, 10_000.0007,
            -1, -1.0004, -1.0007,
            ]

        for (c, x) in zip(doubleChallenges, expected) {
            let shouldMatch = c.pointThree
            XCTAssertEqual(x, shouldMatch)
        }
    }
}

final class MockAccelerometerData {
    let acceleration: CMAcceleration
    var timestamp   : TimeInterval
    init(acceleration: CMAcceleration,
         timestamp: TimeInterval) {
        self.acceleration = acceleration
        self.timestamp   = timestamp
    }
}

class AccelerometerItemTests: XCTestCase {
    // TODO: Imcrement the ticks.
    static let startingTime: TimeInterval = 0
    static let oneTick: TimeInterval = 1.0/200.0
    var clock: TimeInterval = 0

    func stamp(_ mockAccData: MockAccelerometerData) -> MockAccelerometerData {
        mockAccData.timestamp = clock
        clock += Self.oneTick
        return mockAccData
    }

    var accelerations: [CMAcceleration] = [
        .init(x: 0, y: 0, z: 0),
        .init(x: 1, y: 0, z: 0),
        .init(x: 0, y: 1, z: 0),
        .init(x: 0, y: 0, z: 1),
        .init(x: -1, y: 0, z: 0),
        .init(x: 0, y: -1, z: 0),
        .init(x: 0, y: 0, z: -1),
        ]



    var mocAccData: [MockAccelerometerData] = []
    var mockAccelStamps: [TimeInterval] = []
    var accelerometerItems: [AccelerometerItem] = []
    var comparisonCSV: [String] = []

    override func setUpWithError() throws {
        mockAccelStamps = (0..<accelerations.count)
            .map { Double($0) * Self.oneTick }
        accelerometerItems = zip(accelerations, mockAccelStamps)
            .map { (pair) -> AccelerometerItem in
                let (acc, t) = pair
                return AccelerometerItem(timestamp: t, x: acc.x, y: acc.y, z: acc.z)
            }
        comparisonCSV = accelerometerItems
            .map { item in
                let (x, y, z) = (item.x.pointThree, item.y.pointThree, item.z.pointThree)
                let stamp = item.timestamp.pointThree
                return "\(stamp),\(x),\(y),\(z)"
            }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAccelerometerItemCSVFormat() {
        XCTAssertEqual(accelerometerItems.count, comparisonCSV.count, "setup count of items and csv strings")
        for (challenge, expected) in zip(accelerometerItems, comparisonCSV) {
            let derivedCSV = challenge.csv
            XCTAssertEqual(derivedCSV, expected, ".csv versus hand-encoding")
        }
    }


    /*
     Create an item emitter: TaskGrooup, each task being
     for item in accelerometerItems { Task.sleep(oneTick); return item }
     and then run seriatim, right?
     Otherwise the sleeps will have to be the item's timestamp.
     */

}
