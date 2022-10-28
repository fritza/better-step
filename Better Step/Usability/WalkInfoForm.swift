//
//  WalkInfoForm.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/9/22.
//

import SwiftUI

enum WhereWalked: String, Hashable {
    case atHome, awayFromHome
}

enum HowWalked: String, Hashable {
    case straightLine, backAndForth
}

enum EffortWalked: String, Hashable, CaseIterable {
    case light, somewhat, hard
    case veryHard = "Very Hard"
}

struct WalkInfoResult {
    let `where`: String
    let distance: Int

    // FIXME: Incomplete
}

/// A `Form` for the post-usability survey asking about the condition of the subject and the chosen walking area.
struct WalkInfoForm: View, ReportingPhase {
    typealias SuccessValue = WalkInfoResult
    let completion: ClosureType

    init(_ completion: @escaping ClosureType) {
        self.completion = completion
    }

    var summary: String {
        var content = "Info: "
        print((whereWalked == .atHome) ? "Home" : "Away",
              terminator: " ", to: &content)
        print("Length:", lengthOfCourse ?? -1, terminator: " ", to: &content)
        return content
    }

    @EnvironmentObject var resetState: ResetStatus


    @State private var whereWalked: WhereWalked = .atHome
    @State private var howWalked: HowWalked = .straightLine
    @State private var lengthOfCourse: Int? = nil
    @State private var effort: EffortWalked = .somewhat
    @State private var fearOfFalling: Bool = false

    @State private var shouldShowReversionAlert = false

    var body: some View {
        Form {
            // MARK: Home or not
            Section {
                VStack {
                    Text("Where did you perform your walks?")
                    Picker("Where did you walk?",
                           selection: $whereWalked) {
                        Text("At Home")
                            .tag(WhereWalked.atHome)
                        Text("Away from home")
                            .tag(WhereWalked.awayFromHome)
                    }
                           .pickerStyle(.segmented)
                }
            }  // Home/away section
            /*
            Section {
                VStack(alignment: .leading) {
                    Text("About how long was the area you walked in, in feet?").lineLimit(2)
                        .minimumScaleFactor(0.75)
                    HStack {
                        if lengthOfCourse == nil { Text("⚠️") }
                        Spacer()
                        TextField("feet", value: $lengthOfCourse, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .frame(width: 80)
                    }
                }
            }  // length of runway section
             */

/*
 NOT HAPPY with no longer having room for an invalid/empty length flag (⚠️). Nor that while the field format rejects non-numerics, it doesn't show the rejection.
 */

            // MARK: Length of course
            Section {
                TextField("feet", value: $lengthOfCourse, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
//                    .frame(width: 80)
                // Prepend the question text to the number.
                    .safeAreaInset(edge: .leading,
                                   spacing: 12.0
                    ) {
                        Text("In feet, about how long was the area you walked in?")
                            .foregroundColor(
                                (lengthOfCourse == nil) ?
                                    .red : .primary
                            )
                            .frame(maxWidth: 240)
                    }
            }
            // Length of runway

            // MARK: Straight or doubled
            Section {
                VStack {
                    Text("Did you walk back-and-forth, or in a straight line?")
                        .minimumScaleFactor(0.6)
                    Picker("How did you walk?",
                           selection: $howWalked) {
                        Text("Back and Forth")
                            .tag(HowWalked.backAndForth)
                        Text("In a Straight Line")
                            .tag(HowWalked.straightLine)
                    }
                    .pickerStyle(.segmented)                }
            }  // Back-and-forth section

            // MARK: Effort
            Section {
                // FIXME: The app won't let you recover
                //        if you don't change the answer.
                Picker("How hard was your body working?", selection: $effort) {
                    ForEach(EffortWalked.allCases, id: \.rawValue) { effort in
                        Text(effort.rawValue.capitalized)
                            .tag(effort)
                    }
                }
            }   // Effort section

            // MARK: Falling
            Section {
                VStack {
                    Text("Were you concerned about falling during the walks?")
                        .minimumScaleFactor(0.6)
                    Picker("Concerned about falling?",
                           selection: $fearOfFalling) {
                        Text("Yes")
                            .tag(true)
                        Text("No")
                            .tag(false)
                    }
                           .pickerStyle(.segmented)

                }
            }  // falling section
        }
        .onSubmit {
            completion(.success(WalkInfoResult(where: "Home", distance: 200)))
        }
        .safeAreaInset(edge: .top, content: {
            Text("Tell us about your walking conditions — where you chose for your walk, and how you felt while performing it.")
                .padding()
        })
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                ReversionButton(toBeSet: $shouldShowReversionAlert)
                Button("Submit") {
                    completion(.success(WalkInfoResult(where: "Toolbar Submit", distance: 200)))
                }
            }
        }
        .reversionAlert(on: $shouldShowReversionAlert)
    }
}

struct WalkInfoForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalkInfoForm {
                _ in // nothing
            }

                .navigationTitle("Walking Info")
        }
        .environmentObject(ResetStatus())
    }
}
