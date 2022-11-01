//
//  SimplifiedTopView.swift
//  Better Step
//
//  Created by Fritz Anderson on 10/31/22.
//

import SwiftUI

extension TopPhases: CustomStringConvertible {
    static let phaseNames: [TopPhases:String] = [
        .conclusion :    "conclusion",
        .onboarding :    "onboarding",
        .dasi       :    "dasi",
        .failed     :    "failed",
        .usability  :    "usability",
        .walking    :    "walking",
    ]

    var description: String {
        return Self.phaseNames[self]!
    }
}

struct SimplifiedTopView: View {
    @State var currentPhase: TopPhases? {
        didSet {
            print("top currentPhase changes to", currentPhase?.rawValue ?? "NONE")
            print()
        }
    }

    init() {
        //        currentPhase = phase
    }

    var currentPhaseString: String {
        guard let phase = currentPhase else { return "NONE" }
        return phase.description
    }

    @ViewBuilder
    func onboard_view() -> some View {
        OnboardContainerView {
            result in
            do {
                SubjectID.id = try result.get()
                self.currentPhase = .conclusion
            }
            catch {
                fatalError("Can't fail out of an onboarding view")
            }
        }
    }

    var body: some View {
        VStack {
            if currentPhase == nil {
                Text("No phase available")
            }
            else {
                switch currentPhase! {
                case .onboarding:
                    OnboardContainerView {
                        result in
                        do {
                            SubjectID.id = try result.get()
                            self.currentPhase = .conclusion
                        }
                        catch {
                            fatalError("Can't fail out of an onboarding view")
                        }
                    }

                case .conclusion:
                    ConclusionView {
                        _ in
                        currentPhase = .onboarding
                    }
                default:
                    Text("Unhandled phase \(currentPhase?.description ?? "HUH?!")")
                }
            }
        }

        .onAppear {
            currentPhase = .default
        }
    }
}

struct SimplifiedTopView_Previews: PreviewProvider {
    static var previews: some View {
        SimplifiedTopView()
    }
}
