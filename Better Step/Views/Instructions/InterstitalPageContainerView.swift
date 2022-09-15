//
//  InterstitalPageContainerView.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/10/22.
//

import SwiftUI

// MARK: - InterstitalPageTabView
/// A view that flips through ``InterstitialPageView``s using `TabView`’s `page` style.
struct InterstitalPageContainerView: View {
    @State private var showEndOfList = false
    @State private var selectedPage: Int

    private let callback: (() -> Void)?

    private let listing: InterstitialList

    /// Initialize a ``InterstitialPageView``with a list of ``InterstitialInfo`` and an initial page selection.
    /// - Parameters:
    ///   - listing: An ``InterstitialList`` containing the details of the page sequence
    ///   - selection: The **ID** (one-based) of the initially-selected page.
    init(listing: InterstitialList, selection: Int, callback: (() -> Void)? = nil) {
        self.listing = listing
        selectedPage = selection
        self.callback = callback
    }

    // MARK: - Body

    /// Use a `ForEach` to prepare and display the page sequence.
    var body: some View {
        TabView(selection: $selectedPage) {
            ForEach(listing) {
                item in
                InterstitialPageView(info: item) {
                    if item.id < listing.count {
                        selectedPage += 1
                    }
                    else {
                        self.callback?()
                    }
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}


struct InterstitalPageTabView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InterstitalPageContainerView(
                listing: try! InterstitialList(
                    baseName: "walk-intro"),
                selection: 1)
            .padding()
        }
    }
}



