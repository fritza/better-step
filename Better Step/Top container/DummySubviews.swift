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
    var completion: ((Result<Bool, Error>) -> Void)!

    var body: some View {
        VStack {
            Text("Onboard simulator")
            Button("Complete (good)") { completion(.success(true)) }
            Button("Complete (bad)") { completion(.success(false)) }
            Button("Complete (fail)") {
                completion(.failure(DummyFails.onboardFailure))
            }
        }
    }
}

/// A stand-in for the walk container.
///
/// Result type is `Int`, will likely be the full array of measurements
struct DummyWalk: View, ReportingPhase {
    var completion: ((Result<Int, Error>) -> Void)!
    var body: some View {
        VStack {
            Text("Walking simulator")
            Button("Complete (good)") { completion(.success(100)) }
            Button("Complete (bad)") { completion(.success(-10)) }
            Button("Complete (fail)") { completion(.failure(DummyFails.walkingFailure)) }
        }
    }
}

/// A stand-in for the DASI container.
///
/// Result type is `String`, will likely be the CSV-ized answers.
struct DummyDASI: View, ReportingPhase {
    var completion: ((Result<String, Error>) -> Void)!
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
    var completion: ((Result<(String, String), Error>) -> Void)!
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
    var completion: ((Result<Void, Error>) -> Void)!
    var body: some View {
        VStack {
            Text("Congratulations, you're done.")
            Button("Complete (fail)") { completion(
                .failure(DummyFails.conclusionFailure)
                // Why do I have to instantiate Void?
            ) }
        }
    }
}


/// A stand-in for the failure container.
///
/// Result type is `Void`, because there's not much to say.
struct DummyFailure: View, ReportingPhase {
    var completion: ((Result<Void, Error>) -> Void)!
    var body: some View {
        VStack {
            Text("Failure simulator")
            Button("Complete (fail)") { completion(
                .failure(DummyFails.failingFailure)
            ) }
        }
    }
}
