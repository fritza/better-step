//
//  SurveyContainerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/7/22.
//

import SwiftUI


enum DASICardTags: String, CaseIterable, Equatable {
    case landing, questions, completion

    var next: DASICardTags {
        guard let currentIndex = Self.allCases.firstIndex(of: self) else {
            fatalError()
        }
        let nextIndex = (currentIndex+1) % Self.allCases.count
        return Self.allCases[nextIndex]
    }
}

final class DASIContentState: ObservableObject {
    @Published var selected: DASICardTags?

    #warning("no protection from overflow in pageNum")
    // Should detect .questions and number > max question count, then advance the tag.
    // TODO: Should underflow go to landing?
    @Published var pageNum: Int

    init(_ selection: DASICardTags = .landing) {
        selected = selection
        pageNum = 0
    }

    /// Reflect the selection of the next page.
    ///
    /// At the end of the question pages, this should advance to `.completion`. There is no increment from `.completion`.
    func increment() {
        switch selected {
        case .landing:
            pageNum = 1
            selected = .questions
        case .questions:
            if pageNum == DASIQuestion.count {
                selected = .completion
            }
            else {
                pageNum += 1
            }
        default:
            assertionFailure("Attempt to go forward from state \(String(describing: selected))")
            break
        }
    }

    /// Reflect the selection of the previous page.
    ///
    /// From the start of the question pages, this should regress to `.landing`. There is no decrement from `.landing`.
    func decrement() {
        switch selected {
        case .questions:
            if pageNum == 1 {
                selected = .landing
            }
            else {
                pageNum -= 1
            }
        case .completion:
            pageNum = DASIQuestion.count
            selected = .questions
        default:
            assertionFailure("Attempt to go back from state \(String(describing: selected))")
            break
        }
    }

}

struct SurveyContainerView: View {
    @EnvironmentObject var contentEnvt: DASIContentState

    var body: some View {
        NavigationView {
            VStack {
                Text(
                    "SHOULD NOT APPEAR(\(contentEnvt.selected?.rawValue ?? "EMPTY"))"
                )
                Button("RATS Next") {
                    assert(contentEnvt.selected != nil)
                    contentEnvt.selected = contentEnvt.selected?.next
                }
                NavigationLink(tag: DASICardTags.questions,
                               selection: $contentEnvt.selected,
                               destination: {
                    DASIQuestionView()
                        .navigationBarBackButtonHidden(true)
                },
                               label: {EmptyView()}
                )
                NavigationLink(tag: DASICardTags.landing,
                               selection: $contentEnvt.selected,
                               destination: {
                    DASIOnboardView()
                        .navigationBarBackButtonHidden(true)
                },
                               label: {EmptyView()}
                )
                NavigationLink(tag: DASICardTags.completion,
                               selection: $contentEnvt.selected,
                               destination: {
                    DASICardView()
                        .navigationBarBackButtonHidden(true)
                },
                               label: {EmptyView()}
                )
            }
        }
    }
}

struct SurveyContainerView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyContainerView()
            .environmentObject(DASIContentState(.landing))
    }
}

/*
 WORKS: Observing the environment to select self's content.
        Next, how to select the next contained view.
 var body: some View {
     NavigationView {
         VStack {
             Text(contentEnvt.selected.rawValue)
             Button("Next") {
                 contentEnvt.selected = contentEnvt.selected.next
             }
         }
         .navigationTitle("Containment")
     }
 }

 */
