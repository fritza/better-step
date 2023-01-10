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

    @EnvironmentObject var walkingData: WalkInfoResult

    init(_ reporting: @escaping ClosureType) {
        completion = reporting
    }

    // MARK: - How you did
    @ViewBuilder private var howYouDidSection: some View {
        Section("How you did") {
            VStack(alignment: .leading, spacing: 16) {
//                howFarWalkedStack
                howMuchEffortStack
                mightFallStack
            }
        }
    }

    #if false
    @ViewBuilder private var howFarWalkedStack: some View {
        VStack(alignment: .leading) {
            Group {
                Text("About ") +
                Text("how far did you walk").fontWeight(.heavy) +
                Text(", in feet?")
            }
                .lineLimit(2)
                .minimumScaleFactor(0.75)
            HStack {
                Spacer()
                TextField("feet", value: $walkingData.distance, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(width: 80)
                // "Left"-justify the field contents.
                    .multilineTextAlignment(.trailing)
                // Note: "multilineTextAlignment" is documented as alignment for multiline Text.
                //       ATW, the modifier works, but be resigned to that stopping (one hopes
                //       without breakage).
            }
        }
    }
    #endif

    @ViewBuilder private var howMuchEffortStack: some View {
        VStack(alignment: .leading) {
            Text("How hard").fontWeight(.heavy) +
            Text(" was your body working?")

            Picker("", selection: $walkingData.effort) {
                ForEach(EffortWalked.allCases, id: \.rawValue) { effort in
                    Text(effort.rawValue.capitalized)
                        .tag(effort)
                }
            }
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
                   .pickerStyle(.segmented)
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
                   .pickerStyle(.segmented)
        }
    }

    #if false
    // Removed per drubin email 3 Jan 2023 deprecating
    // the text fields as too error-prone
    // MARK: - Length of course
    @ViewBuilder private var lengthOfCourseStack: some View {
        VStack(alignment: .leading) {
            Group {
                Text("About ") +
                Text("how long was the area")
                    .fontWeight(.heavy) +
                Text(" you walked in, in feet?")
            }
            .minimumScaleFactor(0.75)
            .lineLimit(2)

            HStack {
                Spacer()
                TextField("feet", value: $walkingData.lengthOfCourse, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(width: 80)
                // "Left"-justify the field contents.
                    .multilineTextAlignment(.trailing)
                // Note: "multilineTextAlignment" is documented as alignment for multiline Text.
                //       ATW, the modifier works, but be resigned to that stopping (one hopes
                //       without breakage).
            }

        }
    }
    #endif

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
                   .pickerStyle(.segmented)
        }

    }


    // MARK: - body
    var body: some View {
        ScrollViewReader { scrollProxy in
            Form {
                howYouDidSection
                whereYouWalkedSection
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        completion(.success(walkingData.csvLine))
                    }
                }
            }
            .background(.thinMaterial)
        }
        .navigationTitle("Your Walks")
    }
}

struct WalkUsabilityForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalkUsabilityForm {
                _ in print("POP!")
            }
            .environmentObject(WalkInfoResult())
        }
    }
}
