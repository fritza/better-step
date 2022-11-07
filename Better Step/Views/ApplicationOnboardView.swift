//
//  ApplicationOnboardView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import SwiftUI

/// Presented at the beginning of the workflow if no ``SubjectID`` for the user is known.
///
/// Its `SuccessValue` as a ``ReportingPhase`` is `String`.
struct ApplicationOnboardView: View, ReportingPhase {
    @Namespace var appOnboardSpace
    enum Focusables: Hashable {
        case idField
        case submitButton
    }

    typealias SuccessValue = String
    var completion: ClosureType

    let item: TaskInterstitialDecodable

    @State      private var submissionRemarks = ""
    /// Throughout the app, there will be a `@State` `Bool` controlling the visibility of an alert for winding the app back to a virgin state.
    @State      private var shouldWarnOfReversion = false
    @Binding    private var targetString   : String
    @FocusState private var currentFocus: Focusables?

    var fieldIsEmpty: Bool {
        guard let trimmedValue = targetString.trimmed else { return true }
        return trimmedValue.isEmpty // trimmedValue.isEmpty
    }

    var stringIsValid: Bool {
        guard let trimmable = targetString.trimmed else { return false }
        // TODO: Shouldn't we trim it in the field?
        // Probably not, the text would squirt out from under the user.

        return trimmable.isAlphanumeric
    }

    /// Initialize the view given the content information and a button-action closure
    /// - Parameters:
    ///   - info: An ``InterstitialInfo`` specifying text and symbol content.
    ///   - callback: A closure to be called when the action button (**Next**, **Continue**, etc.) is tapped.
    init?(
        string: Binding<String>,
        info: TaskInterstitialDecodable? = nil,
        proceedCallback callback: @escaping ClosureType) {
            self.completion = callback
            _targetString = string
            if let info {
                item = info
            }
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
            currentFocus = .idField
            // The JSON title is ignored in favor of whatever presenting ViewBuilder puts into the navigationTitle.
        }

    private func propagateSuccess() {
        SubjectID.id = targetString
        completion(.success(targetString))
    }


    // MARK: - body
    var body: some View {
            // TODO: Copied directly from InterstitialPageView
            VStack {
                // MARK: Instructional text
                Text(item.introAbove.addControlCharacters)
                    .font(.body)
                    .minimumScaleFactor(0.75)
                Spacer(minLength: 30)
                // MARK: SF Symbol
                Image(systemName: item.systemImage ?? "bolt.slash.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.accentColor)
                    .frame(height: 120)
//                    .symbolRenderingMode(.hierarchical)

                Spacer()
                Text(item.introBelow.addControlCharacters)
                    .font(.body)
                    .minimumScaleFactor(0.75)
                Spacer()

                TaggedField(string: $targetString)
                .onSubmit {
                    guard !targetString.isEmpty else { return }
                    propagateSuccess()
                }
                .focused($currentFocus,
                         equals: .idField)


                // MARK: The action button
                Spacer()
                Button("Submit", action: propagateSuccess)
//                {propagate(success: targetString)}
                .disabled(fieldIsEmpty)
                .navigationTitle("Welcome")
                .focused($currentFocus,
                         equals: .submitButton)
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

    /// **Used in a preview only.**
    final class Edited: ObservableObject {
        @State var editedText: String = ""
    }

    static let edits = Edited()

    static var previews: some View {
        NavigationView {
            VStack {
                ApplicationOnboardView(
                    string: edits.$editedText,
                    info: configuration()!, proceedCallback: { result in
                    if let newID = try? result.get() {
                        edits.editedText = newID
                    }
                })
                .frame(width: .infinity)//, height: 300)
                .padding()

//                Text("value is \(edits.editedText)")
            }
        }
    }
}



