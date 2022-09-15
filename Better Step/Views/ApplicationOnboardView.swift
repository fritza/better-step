//
//  ApplicationOnboardView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import SwiftUI

#warning("Rework to an instructional view")

struct ApplicationOnboardView: View, ReportingPhase {
    let item: InterstitialInfo
    var completion: ((Result<String, Error>) -> Void)!

    @State private var idInProgress: String
    var stringIsValid: Bool {
        guard let trimmable = idInProgress.trimmed else { return false }
        // TODO: Shouldn't we trim it in the field?
        // Probably not, the text would squirt out from under the user.

        return trimmable.isAlphanumeric
    }

    /// Initialize the view given the content information and a button-action closure
    /// - Parameters:
    ///   - info: An ``InterstitialInfo`` specifying text and symbol content.
    ///   - callback: A closure to be called when the action button (**Next**, **Continue**, etc.) is tapped.
    init(info: InterstitialInfo,
         proceedCallback callback: @escaping ((Result<String, Error>) -> Void)) {
        item = info
        self.completion = callback
        idInProgress = SubjectID.id
    }

    /*
     By the way, the exit interstitial should use "hand.thumbsup"
     */


    enum WhereFocused: Hashable {
        case field
        case elsewhere
    }

    // MARK: - body
    var body: some View {
        NavigationView {
            // FIXME: Copied directly from InterstitialPageView
            VStack {
                // MARK: Instructional text
                Text(item.intro)
                    .font(.body)
                    .minimumScaleFactor(0.75)
                Spacer(minLength: 30)
                // MARK: SF Symbol
                Image(systemName: item.systemImage ?? "bolt.slash.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.accentColor)
                    .frame(height: 200)
                    .symbolRenderingMode(.hierarchical)
                Spacer()
                // MARK: Disclaimer
                // FIXME: Remove once the issues are resolved.
                Text("No “Back” button, should that be wanted. A possibly unwanted feature: swipe across the screen to change the page.").font(.caption).minimumScaleFactor(0.5).foregroundColor(.red)
                // MARK: The action button
                Button(item.proceedTitle) {
                    SubjectID.id = idInProgress.trimmed ?? ""
                    #warning("Don't operate on SubjectID.")
                    //       let the container handle it.
                    completion(.success(SubjectID.id))
                }
            }
            .navigationTitle(item.pageTitle)
        }
    }
}

struct OnboardView_Previews: PreviewProvider {
    static func configuration() -> InterstitialInfo {
        let url = Bundle.main.url(forResource: "onboard-intro", withExtension: "json")!
        let jsonData = try! Data(contentsOf: url)
        let rawList = try! JSONDecoder()
            .decode(InterstitialList.self,
                    from: jsonData)
        return rawList.first!
    }

    static var previews: some View {
        ApplicationOnboardView(info: configuration(), proceedCallback: { result in
            if let newID = try? result.get() {
                print("Returned", newID)
            }
        })
        .frame(width: .infinity)//, height: 300)
        .padding()
    }
}



