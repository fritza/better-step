//
//  ApplicationOnboardView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import SwiftUI

struct ApplicationOnboardView: View, ReportingPhase {
    let item: TaskInterstitialDecodable
    var completion: ((Result<String, Error>) -> Void)

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
                print("Bad decoding:", error)
                fatalError("trying to decode \(error)")
                return nil
            }
        }
        // The JSON title is ignored in favor of whatever presenting ViewBuilder puts into the navigationTitle.
    }

    // MARK: - body
    var body: some View {
            // TODO: Copied directly from InterstitialPageView
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
                    .frame(height: 120)
                    .symbolRenderingMode(.hierarchical)

                TaggedField(subject: SubjectID.id) {
                    // TODO: Handle .failure.
                    result in
                    if let newID = try? result.get() {
                        SubjectID.id = newID
                    }
                    completion(.success(SubjectID.id))
                }
                // MARK: The action button
                Spacer()
                Button("Submit") {
                    completion(.success("S101"))
                }
                Spacer()
                Text("Setting the ID should change the landing page and omit the DASI/usability phases. For beta, the gear button can reset the app.\n\nA subject ID is required but not yet enforced.")
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
            print("Bad decoding:", error)
            fatalError("trying to decode \(error.localizedDescription)")
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



