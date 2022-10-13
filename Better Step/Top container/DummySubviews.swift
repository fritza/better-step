//
//  DummySubviews.swift
//  Better Step
//
//  Created by Fritz Anderson on 9/14/22.
//

import SwiftUI
import CoreMotion

// onboarding, walking, dasi, usability, conclusion / failed

// MARK: Branch views

/// A stand-in for the onboarding container.
///
/// Result type is `String`, the recorded subject ID
struct DummyOnboard: View, ReportingPhase {
    typealias SuccessValue = String
    let completion: ClosureType
    init(_ closure: @escaping ClosureType) {
        self.completion = closure
    }

    let resultingSubjectID = "DummyOnboardID"

    var body: some View {
        VStack {
            Text("Onboard simulator")
            Button("Complete") { completion(.success(resultingSubjectID)) }
        }
    }
}

/// A stand-in for the walk container.
///
/// Result type is `Int`, will likely be the full array of measurements
struct DummyWalk: View, ReportingPhase {
    typealias SuccessValue = [CMAccelerometerData]
    let completion: ClosureType
    init(_ closure: @escaping ClosureType) {
        completion = closure
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Walking simulator")
            Button("Complete (dasi)") { completion(.success([])) }
            Button("Complete (fail)") { completion(.failure(DummyFailures.walkingFailure)) }
        }
    }
}

/// A stand-in for the DASI container.
///
/// Result type is `String`, will likely be the CSV-ized answers.
struct DummyDASI: View, ReportingPhase {
    typealias SuccessValue = String
    let completion: ClosureType
    init(_ closure: @escaping ClosureType) {
        completion = closure
    }
    var body: some View {
        VStack {
            Text("DASI simulator")
            Button("Next") {
                completion(.success("DASI responses here"))
            }
        }
    }
}

/// A stand-in for the usability container.
///
/// Result type is `(String, String)`, representing the ratings and the detail responses. The second item might be some kind of `struct` representing those answers.
struct DummyUsability: View, ReportingPhase {
    typealias SuccessValue = (String, String)
    var completion: ClosureType
    init(_ closure: @escaping ClosureType) {
        self.completion = closure
    }

    var body: some View {
        VStack {
            Text("Usability simulator")
            Text("Tapping “Completed” does nothing")
                .font(.caption)
            Button("Completed") { completion(.success(
                ("Good ratings", "Good conditions"))) }
        }
    }
}

/// A stand-in for the conclusion container.
///
/// Result type is `Void`, because there's not much to say.
struct DummyConclusion: View, ReportingPhase {
    typealias SuccessValue = Void

    var completion: ClosureType
    init(_ closure: @escaping ClosureType) { self.completion = closure }

    var body: some View {
        VStack {
            Text("Congratulations, you're done.")
            Button("Complete (fail)") { completion(
                .failure(DummyFailures.conclusionFailure)
                // Why do I have to instantiate Void?
            ) }
        }
    }
}


/// A stand-in for the failure container.
///
/// Result type is `Void`, because there's not much to say.
struct DummyFailure: View, ReportingPhase {
    typealias SuccessValue = Void

    var completion: ClosureType
    init(_ closure: @escaping ClosureType) { completion = closure }

    var body: some View {
        VStack {
            Text("Failure simulator")
            Button("Complete (fail)") { completion(
                .failure(DummyFailures.failingFailure)
            ) }
        }
    }
}
