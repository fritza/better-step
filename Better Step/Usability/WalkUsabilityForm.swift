//
//  WalkUsabilityForm.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/7/22.
//

import Foundation
import SwiftUI

// MARK: - WalkUsabilityForm
/// Editor for all usability data except for the 1–7 ratings.
///
/// Its ``ReportingPhase`` result type is ``WalkInfoResult``.
struct WalkUsabilityForm: View, ReportingPhase {
    @Namespace var lastFormSection
    typealias SuccessValue = String
    let completion: ClosureType

    @StateObject var walkingData: WalkInfoResult = WalkInfoResult()

    init(_ reporting: @escaping ClosureType) {
        completion = reporting
    }

    // MARK: - How you did
    @ViewBuilder private var howYouDidSection: some View {
        Section("How you did") {
            VStack(alignment: .leading, spacing: 16) {
                howMuchEffortStack
                mightFallStack
            }
        }
    }

    @ViewBuilder private var howMuchEffortStack: some View {
        VStack(alignment: .leading) {
            Text("How hard").fontWeight(.heavy) +
            Text(" was your body working?")

            Picker("", selection: $walkingData.effort) {
                ForEach(EffortWalked.allCases) { effort in
                    Text(effort.label)
                        .tag(effort)
                }
            }
            .pickerStyle(.menu)
        }
    }

    @ViewBuilder private var mightFallStack: some View {
        VStack(alignment: .leading) {
            Group {
                Text("Were you ") +
                Text("concerned about falling").fontWeight(.heavy) +
                Text(" during the walks?")
            }
            .minimumScaleFactor(0.6)
            Picker("Concerned about falling?",
                   selection: $walkingData.fearOfFalling) {
                Text("Yes")
                    .tag(true)
                Text("No")
                    .tag(false)
            }
//                   .pickerStyle(.segmented)
        }
    }



    // MARK: - Where you walked

    @ViewBuilder private var whereYouWalkedSection: some View {
        Section("Where you walked") {
            wherePerformedStack
//            lengthOfCourseStack
            backAndForthStack
                .tag(lastFormSection)
        }
    }

    // MARK: - Where performed
    @ViewBuilder private var wherePerformedStack: some View {
        VStack(alignment: .leading) {
            Group {
                Text("Where did you perform").fontWeight(.heavy) +
                Text(" your walks?")
            }
            Picker("Where did you walk?",
                   selection: $walkingData.where) {
                Text("At Home")
                    .tag(WhereWalked.atHome)
                Text("Away from home")
                    .tag(WhereWalked.awayFromHome)
            }
//                   .pickerStyle(.segmented)
        }
    }

    // MARK: - Linear or circuit
    @ViewBuilder private var backAndForthStack: some View {
        VStack(alignment: .leading) {
            Group {
                Text("Did you walk ") +
                Text("back-and-forth").fontWeight(.heavy) +
                Text(", or in a ") +
                Text("straight line?").fontWeight(.heavy)
            }
            .minimumScaleFactor(0.6)
            Picker("How did you walk?",
                   selection: $walkingData.howWalked) {
                Text("Back and Forth")
                    .tag(HowWalked.backAndForth)
                Text("In a Straight Line")
                    .tag(HowWalked.straightLine)
            }
        }
    }


    // MARK: - body
    var body: some View {
        ScrollViewReader { scrollProxy in
            Form {
                howYouDidSection
                whereYouWalkedSection
//                    .background(Color.purple)
            }
            .formStyle(.grouped)
//            .background(.thinMaterial)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        print("After usability form DONE:", walkingData)
                        print("After usability form DONE:", "“\(walkingData.csvLine)”")
                        completion(.success(walkingData.csvLine))
                    }
                }
            }
        }
        .pickerStyle(.segmented)
    }
}

struct WalkUsabilityForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalkUsabilityForm {
                result in
                let result = try! result.get()
                print("result is now", result)
            }
        }
    }
}
