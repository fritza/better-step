//
//  WalkInfoForm.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/9/22.
//

import SwiftUI

/// A `Form` for the post-usability survey asking about the condition of the subject and the chosen walking area.
///
/// The `SuccessValue` as a ``ReportingPhase`` is `Void`, just a notification that the form has been committed.
struct WalkInfoForm: View, ReportingPhase {
    typealias SuccessValue = Void
    let completion: ClosureType

    @EnvironmentObject var walkInfoContent: WalkInfoResult

    init(_ completion: @escaping ClosureType) {
        self.completion = completion
    }

    var summary: String {
        var content = "Info: "
        print((walkInfoContent.where == .atHome) ? "Home" : "Away",
              terminator: " ", to: &content)
        print("Length:", walkInfoContent.lengthOfCourse ?? -1, terminator: " ", to: &content)
        return content
    }

//    @State private var whereWalked: WhereWalked = .atHome
//    @State private var howWalked: HowWalked = .straightLine
//    @State private var lengthOfCourse: Int? = nil
//    @State private var effort: EffortWalked = .somewhat
//    @State private var fearOfFalling: Bool = false

    @State private var shouldShowReversionAlert = false

    /*
     NOT HAPPY with no longer having room for an invalid/empty length flag (⚠️). Nor that while the field format rejects non-numerics, it doesn't show the rejection.
     */

    @ViewBuilder
    var whereWalkedSection: some View {
        Section {
            VStack {
                Text("Where did you perform your walks?")
                Picker("Where did you walk?",
                       selection: $walkInfoContent.where) {
                    Text("At Home")
                        .tag(WhereWalked.atHome)
                    Text("Away from home")
                        .tag(WhereWalked.awayFromHome)
                }
                       .pickerStyle(.segmented)
            }
        }
    }

    @ViewBuilder
    var walkingLengthSection: some View {
        Section {
            VStack(alignment: .leading) {
                Text("How far did you walk, in feet?").lineLimit(2)
                    .minimumScaleFactor(0.75)
                HStack {
//                    if walkInfoContent.distance == nil { Text("⚠️") }
                    Spacer()
                    TextField("feet", value: $walkInfoContent.distance, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                }
            }
        }
    }



    @ViewBuilder
    var courseLengthSection: some View {
        Section {
            VStack(alignment: .leading) {
                Text("About how long was the area you walked in, in feet?").lineLimit(2)
                    .minimumScaleFactor(0.75)
                HStack {
                    if walkInfoContent.lengthOfCourse == nil { Text("⚠️") }
                    Spacer()
                    TextField("feet", value: $walkInfoContent.lengthOfCourse, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                }
            }
        }
    }

    @ViewBuilder
    var doubledSection: some View {
        Section {
            VStack {
                Text("Did you walk back-and-forth, or in a straight line?")
                    .minimumScaleFactor(0.6)
                Picker("How did you walk?",
                       selection: $walkInfoContent.howWalked) {
                    Text("Back and Forth")
                        .tag(HowWalked.backAndForth)
                    Text("In a Straight Line")
                        .tag(HowWalked.straightLine)
                }
                       .pickerStyle(.segmented)
            }
        }  // Back-and-forth section

    }

    @ViewBuilder
    var effortSection: some View {
        Section {
            // FIXME: The app won't let you recover
            //        if you don't change the answer.
            Picker("How hard was your body working?", selection: $walkInfoContent.effort) {
                ForEach(EffortWalked.allCases, id: \.rawValue) { effort in
                    Text(effort.rawValue.capitalized)
                        .tag(effort)
                }
            }
        }
    }

    @ViewBuilder
    var fallingSection: some View {
        Section {
            VStack {
                Text("Were you concerned about falling during the walks?")
                    .minimumScaleFactor(0.6)
                Picker("Concerned about falling?",
                       selection: $walkInfoContent.fearOfFalling) {
                    Text("Yes")
                        .tag(true)
                    Text("No")
                        .tag(false)
                }
                       .pickerStyle(.segmented)
            }
        }  // falling section
    }

    var body: some View {

// EXPECT walkInfoContent == nil

        Form {
            whereWalkedSection
            courseLengthSection
            doubledSection
            walkingLengthSection
            effortSection
            fallingSection
        }
        .onSubmit {
            completion(.success(()))
        }
        .safeAreaInset(edge: .top, content: {
            Text("Tell us about your walking conditions — where you chose for your walk, and how you felt while performing it.")
                .padding()
        })
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                ReversionButton(toBeSet: $shouldShowReversionAlert)
                Button("Submit") {
                    completion(.success(()))
                }
            }
        }
        .reversionAlert(on: $shouldShowReversionAlert)
    }
}

final class DisplayWalkInfo: View, ObservableObject {
//    @State var represented: WalkInfoResult
    @EnvironmentObject var result: WalkInfoResult
//
//    init(representing: WalkInfoResult) {
//        represented = representing
//    }

    var body: some View {
        Text("\(result.description)")
//            .environmentObject(represented)
    }
}

struct WalkInfoForm_Previews: PreviewProvider {
    static var walkResult = WalkInfoResult()

    static var previews: some View {
        NavigationView {
            DisplayWalkInfo() //representing: walkResult)
            WalkInfoForm() {
                _ in // nothing

            }

            .navigationTitle("Walking Info")
        }
        .environmentObject(walkResult)
    }
}
