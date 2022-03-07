//
//  SurveyContainerView.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/7/22.
//

import SwiftUI


enum CardTags: String, CaseIterable, Equatable {
    case landing, questions, completion

    var next: CardTags {
        guard let currentIndex = Self.allCases.firstIndex(of: self) else {
            fatalError()
        }
        let nextIndex = (currentIndex+1) % Self.allCases.count
        return Self.allCases[nextIndex]
    }
}

final class ContentState: ObservableObject {
    @Published var selected: CardTags?
    @Published var pageNum: Int
    init(_ selection: CardTags = .landing) {
        selected = selection
        pageNum = 0
    }
}

struct SurveyContainerView: View {
    @EnvironmentObject var contentEnvt: ContentState

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
                NavigationLink(tag: CardTags.second,
                               selection: $contentEnvt.selected,
                               destination: {
                    QuestionView()
                        .navigationBarBackButtonHidden(true)
                },
                               label: {EmptyView()}
                )
                NavigationLink(tag: CardTags.first,
                               selection: $contentEnvt.selected,
                               destination: {
                    DASIOnboardView()
                        .navigationBarBackButtonHidden(true)
                },
                               label: {EmptyView()}
                )
                NavigationLink(tag: CardTags.third,
                               selection: $contentEnvt.selected,
                               destination: {
                    CardView()
                        .navigationBarBackButtonHidden(true)
                },
                               label: {EmptyView()}
                )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyContainerView()
            .environmentObject(ContentState(.landing))
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
