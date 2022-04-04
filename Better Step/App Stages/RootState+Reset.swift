//
//  RootState+Reset.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/23/22.
//

import Foundation

/// Adopters can initialize themselves and provide instances of themselves set to "fresh" values.
///
/// Objects are free to reset and return themselves as fresh. This is frequent enough that the fresh-setup `func` is defaulted to the teardown.
protocol SubjectIDDependent {
    /// Reset self to as-new or `nil` condition.
    ///
    /// The return value is what an existing value or reference should be reset to, including `nil`.
    ///
    /// - note: In practice, client code will know whether clearing or resetting of `var`s to the retured values is necessary. Don't be daunted by the generalized design.
    /// - returns: An instance of `Self` reflecting the cleared state; this may be `self`; or `nil` if "cleared" means uninitialized.
    @discardableResult
    func teardownFromSubjectID() async throws -> Self?

    /// Return an optional instance of `self` that depends on a new subject ID.
    ///
    /// **Default implementation:** Returns the result of `teardownFromSubjectID()`
    /// - parameter newID: The new subject ID with which to initialize the new object
    /// - returns: The value or reference existing variables should hold. `nil` is allowed, but not expected to be likely.
    func setUpWithSubjectID(_ newID: String) async throws -> Self?
}

extension SubjectIDDependent {
    func setUpWithSubjectID(_ newID: String) async throws -> Self? {
        return try await teardownFromSubjectID()
    }
}

extension RootState {
    func observeSubjectID() {
        subjectIDState.$subjectID
        // Ignore incidental re-setting
            .removeDuplicates()
        // Wait between keystrokes
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { id in
                if let id = id {
                    // See NOTES below on requirements for clearing
                    // COMMON
                    AppStage.shared.makeAllIncomplete()


                }
                else {
                    // subject ID -> nil

                }

            }
            .store(in: &cancellables)
    }

/*  MARK: - NOTES

 If there's a lagging state (file actors, etc.), proceed as if -> nil
 Either way, then proceed as to create.

 nil or subject ID -> different subject ID
 Destroy existing subject ID stuff
   - DASI
      - file (the File actor)
      - DASI in-memory content
      - Bail from DASI page? Or can we trust no ∆ID while it's visible?

   - Walk
      - file
      - record (the Sink actor).

  - completion
      - un-complete all.


 Identify existing structure by the lagging references to the file, records, etc.

 If -> "", set to nil?
 TODO: Make onboarding nil the observed ID when field is empty.
*/

/*
 No state, looks up sID dynamically:
    PerSubjectFileCoordinator
    DASIPages

 sID is captured on init(), or has side effects, e.g. creating files/directories.
    - dasiFile: DASIReportFile
 */

    func tearDownFromSubject() throws {
        // Actually, just give everything a protocol for what it does when the existing sID disappears.
        Task {
            AppStage.shared.makeAllIncomplete()
            allTasksFinished = false

            if dasiFile != nil {
                try await dasiFile!.teardownFromSubjectID()
                dasiFile = nil
            }
            dasiResponses.clearResponses()
            try await dasiContent.teardownFromSubjectID()

            // TODO: MAKE SURE this is the right thing to do.
            //       ATW the only caller is the clear-all button in SetupView > ClearingView

            SubjectID.clear()
        }
    }

    func respondToNewSubject(_ new: String) throws {
        AppStage.shared.makeAllIncomplete()

       dasiFile = try DASIReportFile(
           baseName: "DASI",
           directory: PerSubjectFileCoordinator.shared.directoryURLForSubject(creating: true)
       )
    }
}
