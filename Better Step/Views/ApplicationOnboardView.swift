//
//  ApplicationOnboardView.swift
//  Better Step
//
//  Created by Fritz Anderson on 1/28/22.
//

import SwiftUI

#warning("loading a 2-card JSON for a 1-card context.")


/// Presented at the beginning of the workflow if no ``SubjectID`` for the user is known.
///
/// Its ``SuccessValue`` as a ``ReportingPhase`` is `String`.
/// - note: This view is ultimately contained in a `NavigationView` in ``TopContainerView``

/// - note: There was some idea of having the onboard/return in a single `View` with lots of conditionals. This is insane. See ``ApplicationGreetingView`` instead.
struct ApplicationOnboardView: View, ReportingPhase {
    @Namespace var appOnboardSpace
    enum Focusables: Hashable {
        case idField
        case submitButton
    }
    
    typealias SuccessValue = String
    var completion: ClosureType
    
    let item: TaskInterstitialDecodable
    
    @State      private var workingString = SubjectID.id
    /// Throughout the app, there will be a `@State` `Bool` controlling the visibility of an alert for winding the app back to a virgin state.
    @Binding    private var targetString   : String
    @FocusState private var currentFocus: Focusables?
        
    private var isEntryAcceptable: Bool {
        workingString.asValidSubjectID != nil
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
                    
#warning("loading a 2-card JSON for a 1-card context.")
                    
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
        // Propagate the result string (from onSubmit or Submit button)
        // downstream to OnboardContainerView,
        // which propagates to TopContainerView,
        // which sets SubjectID.id.
        completion(.success(workingString))
    }
    
    // MARK: - body
    var body: some View {
        // TODO: Copied directly from InterstitialPageView
        VStack {
            Text("Welcome").font(.largeTitle)
            Spacer()
#warning("Port GenericContainer view")
            // ... as much as possible, having the
            // text field breaks the GCV model.
            // MARK: Instructional text
            Text((item.contentAbove ?? "Can't Happen").addControlCharacters)
                .font(Rendering.bodyFont)
                .minimumScaleFactor(Rendering.textMinScale)
            Spacer(minLength: 30)
            // MARK: SF Symbol
            Image(systemName: item.systemImage ?? "bolt.slash.fill")
                .scaledAndTinted()
                .frame(height: 200)
            
            Spacer()
            Text((item.contentBelow ?? "Can't Happen").addControlCharacters)
                .minimumScaleFactor(Rendering.textMinScale)
                .font(.callout)
            Spacer()
            
            Divider()
            
            Group {
                TaggedField(string: $workingString)
                    .onSubmit {
                        guard let str = workingString.asValidSubjectID else { return }
                        targetString = str
//                        guard !targetString.isEmpty else { return }
                        propagateSuccess()
                    }
                    .font(.title)
                    .focused($currentFocus,
                             equals: .idField)
                
                Text("Subject IDs consist of a single letter followed by a four-digit number from 1000 to 9999.")
                    .font(.callout)
                
                // MARK: The action button
                Spacer()
                Button("Submit") { propagateSuccess() }
                    .disabled(!isEntryAcceptable)
                    .focused($currentFocus, equals: .submitButton)
            }
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
            }
        }
    }
}



