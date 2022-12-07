//
//  WalkInfoContainer.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/2/22.
//

import SwiftUI

#error("Misleading names "WalkInfo"~ for information on USABILITY AS TO walking.")

typealias WalkInfoCompletion = (Int) -> Void

struct NumberedPageView: View {
    let index: Int
    let completion: WalkInfoCompletion

    init(index: Int, completion: @escaping WalkInfoCompletion) {
        self.index = index
        self.completion = completion
    }

    var body: some View {
        VStack {
            Text("number \(index) view").font(.largeTitle)
            Spacer()
            Button("Continue") {
                completion(+1)
            }
            // The back button should be there already
            // The question is, how does the default back button
            // signal to the container view that it should wind
            // back to the previous state?
            // And if focus does cross over into the major section
            //      (intro - < Back - Form pages)
            // How do the form pages know to start at the end?

            // OR! Maybe just restart the form from the top
            // It's not lengthy, and is the safer way to orient the
            // user that further < Back won't get her any earlier
            // in the form.
        }
        .navigationBarTitle("Finished")
    }
}

struct IntroPageView: View {
    let completion: WalkInfoCompletion

    init(completion: @escaping WalkInfoCompletion) {
        self.completion = completion
    }

    var body: some View {
        VStack {
            Spacer()
            Text("introduction").font(.largeTitle)
            Spacer()
            Button("Continue") {
                completion(+1)
            }
        }
        .navigationBarTitle("Conditions")
    }
    // How do I hide the back button at the start?
    // the operation is permitted in a NavigationItem.
    // Easy: hide the back button (if used at all)
    //       Install a toolbar with Back/Continue as needed (hide one at an extremum)
}

struct ClosingPageView: View {
    let completion: WalkInfoCompletion

    init(_ completion: @escaping WalkInfoCompletion) {
        self.completion = completion
    }

    var body: some View {
        VStack {
            Spacer()
            Text("Closing").font(.largeTitle)
            Spacer()
            Button("(Continue)") {
                completion(0)
            }
        }
        .navigationBarTitle("Conditions")
    }
    // How do I hide the back button at the start?
}

struct FormPageView: View {
    let index: Int
    let completion: WalkInfoCompletion

    init(_ index: Int, completion: @escaping WalkInfoCompletion) {
        self.index = index
        self.completion = completion
    }

    var body: some View {
        VStack {
            Spacer()
            Text("page \(index)").font(.largeTitle)
            Spacer()
            Button("Next") {
                completion(+1)
            }
        }
        .navigationBarTitle("Conditions")
    }
}

private let formPageCount = 3
private let afterFormIndex = 1000

/// Presents a `TabView` displaying partial forms to describe experience and conditions of the walk on first run of the app, e.g., indoors, outdoors, back-and-forth, length of track…
///
/// The overall sequence is intro ``IntroPageView``, (3x) form page (``FormPageView``), and exit (``ClosingPageView``).
///
/// There are also toolbar buttons for forward and back.
/// - warning: The page views are not yet written. Having a single type for three pages of different content worrreis ma.
struct WalkInfoContainer: View {
    /*
     Page 0 is the interstitial
     pages 1...n are form sections
     page 1000 is the completion.
     */

    @State private var formPage: Int

    init(_ page: Int = 0) {
        formPage = 0
    }

    var body: some View {
        //        Color.green.frame(height: 100)
        TabView(selection: $formPage, content: {
            // MARK: Intro
            IntroPageView(completion: { _ in formPage = 1 } )
                .tag(0)

            // MARK: Frames
            ForEach(1...formPageCount, id: \.self) {
                formIndex in
                FormPageView(formIndex, completion:  {
                    increment in
                    if formIndex + increment > formPageCount {
                        formPage = afterFormIndex
                    } else {
                        formPage += increment
                    }
                })
                .tag(formIndex)
            }

            // MARK: Closing
            ClosingPageView {
                _ in formPage = afterFormIndex
            }
            .tag(afterFormIndex)

        })
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                // MARK: Toolbar - Back
                Button("˂ Back") {
                    if formPage < 1 {
                        //  do nothing
                    }
                    else if formPage == afterFormIndex {
                        formPage = formPageCount
                    }
                    else {
                        formPage -= 1
                    }
                }
                .disabled(formPage == 0)
                .font(.title2)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                // MARK: Toolbar - Next
                Button("Next ˃") {
                    if formPage >= afterFormIndex {
                        // do nothing
                    }
                    else if formPage == formPageCount {
                        formPage = afterFormIndex
                    }
                    else {
                        formPage += 1
                    }
                }
                .disabled(formPage == afterFormIndex)
                .font(.title2)
            }
        }
        )
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("Forms")
    }
}

struct WalkInfoContainer_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Color.red.frame(width: .infinity, height: 100)
            VStack {
                WalkInfoContainer()
            }
            Color.green.frame(width: .infinity, height: 100)
        }
    }
}
