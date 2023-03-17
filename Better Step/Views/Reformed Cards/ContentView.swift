//
//  ContentView.swift
//  Gallery
//
//  Created by Fritz Anderson on 3/14/23.
//

import SwiftUI

let jsonNames = [
    "onboard-intro", "Volume", "second-walk-intro",
    "usability-intro", "walk-intro",
    ]

/// A `List` displaying the base names of the ``CardContent`` JSON files, which describe a series of ``SimplestCard``. Tapping one reveals an ``InterCarousel`` to browse the rendered content for one file.
struct ContentView: View {
    @State private var selectedItem : String?
    @State private var navStack     : [[CardContent]] = []
    let interstitialComplete        : () -> Void
    
    init(completedAll: @escaping () -> Void) {
        interstitialComplete = completedAll
    }
    
    @State private var listsVisited: Set<String> = []
    
    var body: some View {
        NavigationStack(path: $navStack) {
            List(jsonNames, id: \.self) {
                name in
                NavigationLink(
                    value: try! CardContent.contentArray(from: [name]),
                    label: {
                        Label(name,
                              systemImage:
                                listsVisited.contains(name) ? "checkmark.square" : "square.dotted"
                        ) }
                    // Label: Ideally, name is added to a "listVisited" Set
                    // upon completion of InterCarousel, but "name" is lost
                    // after this point.
                )
            }
            .navigationDestination(for: [CardContent].self) { content in
                InterCarousel(content: content) {
                    if navStack.count > 1 {
                        navStack = navStack.dropLast(1)
                    }
                    interstitialComplete()
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView() {
            print(#function, "content exhausted.")
        }
    }
}
