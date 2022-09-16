//
//  ApplicationOnboardView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import SwiftUI

struct ApplicationOnboardView: View, ReportingPhase {
    let item: TaskInterstitialDecodable
    var completion: ((Result<String, Error>) -> Void)!

    @State private var submissionRemarks = ""
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
    init?(info: TaskInterstitialDecodable? = nil,
         proceedCallback callback: @escaping ((Result<String, Error>) -> Void)) {
        self.completion = callback
        idInProgress = SubjectID.id
        if let info { item = info }
        else {
            do {
                guard let url = Bundle.main.url(forResource: "onboard-intro", withExtension: "json") else {
                    throw FileStorageErrors.cantFindURL(#function)
                }
                let jsonData = try Data(contentsOf: url)
                let rawList = try JSONDecoder()
                    .decode([TaskInterstitialDecodable].self,
                            from: jsonData)
                item = rawList.first!
            }
            catch {
                fatalError("trying to decode \(error)")
                print("Bad decoding:", error)
                return nil
            }
        }
        // The JSON title is ignored in favor of whatever presenting ViewBuilder puts into the navigationTitle.
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
            // FIXME: Copied directly from InterstitialPageView
            VStack {
                // MARK: Instructional text
                Text(item.intro.addControlCharacters)
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
                /*
                TaggedField(subject: SubjectID.id, callback: { result in
                    if let trim = result.trimmed,
                       trim.isAlphanumeric {
                        submissionRemarks = "valid: \(trim)"
                        completion(.success(trim))
                    }
                    else {
                        submissionRemarks = "not valid: “\(result)”"
                    }
                })
                Text(submissionRemarks)
                Spacer()
                // MARK: Disclaimer
                // FIXME: Remove once the issues are resolved.
                Group {
                    Text("Tap the return key to submit. Further validation will come in a later build")
                    Text("\nNo “Back” button, should that be wanted. A possibly unwanted feature: swipe across the screen to change the page.")
                }.font(.caption).minimumScaleFactor(0.5).foregroundColor(.red)
                 */
                // MARK: The action button
                Button("Submit") {
                    completion(.success("S101"))
                }
                Spacer()
                Text("This page will have a text field to create a user ID. For now, tap “Submit.”\n\nAfter an ID is set, there will be a different landing page, because the subject ID cannot be changed.")
                    .font(.caption).minimumScaleFactor(0.5).foregroundColor(.red)
            .navigationTitle("Welcome")
        }
    }
}

struct OnboardView_Previews: PreviewProvider {
    static func configuration() -> TaskInterstitialDecodable? {
        do {
            guard let url = Bundle.main.url(forResource: "onboard-intro", withExtension: "json") else {
                throw FileStorageErrors.cantFindURL(#function)
            }
            let jsonData = try Data(contentsOf: url)
            let rawList = try JSONDecoder()
                .decode([TaskInterstitialDecodable].self,
                        from: jsonData)
            return rawList.first!
        }
        catch {
            fatalError("trying to decode \(error.localizedDescription)")
            print("Bad decoding:", error)
            return nil
        }
    }

    static var previews: some View {
        NavigationView {
            ApplicationOnboardView(info: configuration()!, proceedCallback: { result in
                if let newID = try? result.get() {
                    print("Returned", newID)
                }
            })
            .frame(width: .infinity)//, height: 300)
            .padding()
        }
    }
}



