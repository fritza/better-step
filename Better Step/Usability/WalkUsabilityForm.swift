//
//  WalkUsabilityForm.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/7/22.
//

import Foundation
import SwiftUI

struct WalkUsabilityForm: View, ReportingPhase {
    @Namespace var lastFormSection
    typealias SuccessValue = WalkInfoResult
    let completion: ClosureType

    @EnvironmentObject var walkingData: WalkInfoResult

    @State var seeingBottomCount: Int = 0
    @State var hasSeenBottom: Bool = false
    @State var shouldDisplayDoneAlert: Bool = false

    init(_ reporting: @escaping ClosureType) {
        completion = reporting
    }



    // FIXME: Still doesn't help.
    //        The proxy goes out of scope in the
    //        .toolbar definition.
    func scrollToBottom(of proxy: ScrollViewProxy) {
        proxy.scrollTo(lastFormSection, anchor: .bottom)
    }

    // MARK: - How you did
    @ViewBuilder private var howYouDidSection: some View {
        Section("How you did") {
            VStack(alignment: .leading, spacing: 16) {
                howFarWalkedStack
                howMuchEffortStack
                mightFallStack
            }
        }
    }

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
                //                    if walkInfoContent.distance == nil { Text("⚠️") }
                Spacer()
                TextField("feet", value: $walkingData.distance, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(width: 80)
            }
        }
    }

    @ViewBuilder private var howMuchEffortStack: some View {
//        VStack {
            Picker("How hard was your body working?", selection: $walkingData.effort) {
                ForEach(EffortWalked.allCases, id: \.rawValue) { effort in
                    Text(effort.rawValue.capitalized)
                        .tag(effort)
                }
//            }
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
            lengthOfCourseStack
            backAndForthStack
                .tag(lastFormSection)
        }
    }

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
                //                                .padding()
            }
            //                        }

        }
    }

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
                   .onAppear {
                       seeingBottomCount += 1
                       hasSeenBottom = seeingBottomCount >= 2
                   }
        }

    }


    var body: some View {
        ScrollViewReader { scrollProxy in
            Form {
                howYouDidSection
                whereYouWalkedSection
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {

                        if !hasSeenBottom {
                            shouldDisplayDoneAlert = true
                            hasSeenBottom = true


                            // The Done button is tapped.
                            // Has the user scrolled down all the way before?
                            //   (hasSeenBottom)
                            // If not, put the alert up.
                        }
                        else {
                            completion(.success(walkingData))
                        }
                    }
                }
            }
            .background(.thinMaterial)
        }
            .alert("Scroll Down",
                   isPresented: $shouldDisplayDoneAlert,
                   actions: {},
                   message: {
                Text("Please scroll down to review your answers to the items at the end of this list.")
            }
            )
            .navigationTitle("Your Walks")
    }
}

struct WalkUsabilityForm_Previews: PreviewProvider {
    static var previews: some View {
        WalkUsabilityForm {
            _ in print("POP!")
        }
        .environmentObject(WalkInfoResult())
    }
}
