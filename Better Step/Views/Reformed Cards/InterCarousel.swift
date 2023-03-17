//
//  InterCarousel.swift
//  Gallery
//
//  Created by Fritz Anderson on 3/15/23.
//

import SwiftUI

// MARK: - InterCarousel

/// Page-style `TabView` displaying a selected set of interstitial cards, a sequence of single views within a phase of the app.
///
/// Uses a ``CardContent`` array to generate the cards.
/// Generated for the paging `TabView` in ``TempInterstitialHost``

struct InterCarousel: View {
    /// Content specifications of the cards to display.
    let cardContent: [CardContent]
    /// Index of displayed card. Should never be `nil`, but `TabView` insists.
    @State var selectionIndex = 0
    @State var shouldDisableBack: Bool = true
    
    let reportReachedEnd: () -> Void
    
    /// Prepare the view to display a series of cards.
    init(content: [CardContent],
         reportEnded: @escaping () -> Void) {
        assert(!content.isEmpty)
        self.cardContent = content
        self.selectionIndex = 0
        self.shouldDisableBack = true
        self.reportReachedEnd = reportEnded
    }
    
    // MARK: body
    var body: some View {
        VStack {
            BackToolbarView(disabled: selectionIndex == 0) {
                decrementingIndexInBounds()
            }
            
            TabView(selection: $selectionIndex) {
                ForEach(cardContent) { content in
                    SimplestCard(content: content) {
                        if !incrementingIndexInBounds() {
                            reportReachedEnd()
                        }
                    }
                    .tabItem {
                        Label(content.pageTitle, systemImage: "star")
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .tabViewStyle(.page(indexDisplayMode: .never))
        .padding()
    }
    
    /// If `selectedIndex+1` would be in bounds, add one to `selectedIndex` and return `true`. Otherwise do nothing and return `false`.
    /// - Returns: Whether the increment was performed. Discarding may be useful for debugging, but would be a smell.
    @discardableResult
    func incrementingIndexInBounds() -> Bool {
        guard (selectionIndex + 1) < cardContent.count else {
            return false
        }
        selectionIndex += 1
        return true
    }
    
    /// If `selectedIndex-1` would be in bounds `(>= 0)`, subtract one from `selectedIndex` and return `true`. Otherwise do nothing and return `false`.
    /// - Returns: Whether the decrement was performed. Discarding may be useful for debugging, but would be a smell.
    @discardableResult
    func decrementingIndexInBounds() -> Bool {
        guard selectionIndex > 0 else {
            return false
        }
        selectionIndex -= 1
        return true
    }
}

struct InterCarousel_Previews: PreviewProvider {
    static var previews: some View {
        if let array = try? CardContent.contentArray(from: "walk-intro") {
            InterCarousel(content: array) {
                print("exhausted contents")
            }
        }
        else {
            Text("Couldn’t load")
        }
    }
}
