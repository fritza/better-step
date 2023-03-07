//
//  CardGalleryView.swift
//  
//
//  Created by Fritz Anderson on 3/6/23.
//

import SwiftUI

protocol CardItemView: View {
    
}



struct CardGalleryView: View {
    let pageSpecs: [OnePage]
    @State private var selectedPageIndex: Int = 0
    
    /*
     The TabView (I bet) uses the OneCard ID, which had been 1 greater than the 0-based index. But the advance/retreat funcs assume zero-based.
     
     
     */
    
    
    
    init(pages: [OnePage]) {
        precondition(pages.count > 0, "Attempt to initilize a gallery with no items.")
        pageSpecs = pages
        selectedPageIndex = 0
    }
    
    init(pageArrayJSON: String) throws {
        let pages = try OnePage.from(jsonArray: pageArrayJSON)
        self.init(pages: pages)
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    retreat()
//                    if selectedPageIndex > 0 { selectedPageIndex -= 1 }
                })  {
                    Text("< Back").font(.title3)
                }
                .disabled(selectedPageIndex <= 0)
                Spacer()
            }.padding()
            
           Divider()
            
            TabView(selection: $selectedPageIndex) {
                ForEach(pageSpecs) { spec in
                    CardView(pageParaams: spec) {
                        let nextIndex = selectedPageIndex + 1
                        print("Selected:", selectedPageIndex)
                        print("next (if any):", nextIndex)
                        print(pageSpecs.count, "pages.")
                        if nextIndex < (pageSpecs.count) {
                            selectedPageIndex = nextIndex
                        }
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .toolbar
            {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        let prevIndex = selectedPageIndex - 1
                        if prevIndex > 0 {
                            selectedPageIndex = prevIndex
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Next") {
                        let nextIndex = selectedPageIndex + 1
                        if nextIndex >= pageSpecs.count {
                            selectedPageIndex = nextIndex
                        }
                    }
                }
            }
        }
        .toolbar(.visible, for: .navigationBar)
    }
        
    @discardableResult
    func advance() -> Bool {
        let nextIndex = selectedPageIndex + 1

        print("Selected:", selectedPageIndex)
        print("next (if any):", nextIndex)
        print(pageSpecs.count, "pages.")

        if nextIndex < (pageSpecs.count) {
            selectedPageIndex = nextIndex
            return true
        }
        return false
    }
    
    @discardableResult
    func retreat() -> Bool {
        let prevIndex = selectedPageIndex - 1
        
        print("Selected:", selectedPageIndex)
        print("previous (if any):", prevIndex)
        print(pageSpecs.count, "pages.")
        
        if prevIndex >= 0 {
            selectedPageIndex = prevIndex
            return true
        }
        return false
    }
}

struct CardGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        try! CardGalleryView(pageArrayJSON: both)
    }
}

/// A `View`, one among many conforming, in an array of `[any PageDisplayed]`.  A Gallery view (e.g. CardGalleryView) would step through these so you can display JSON-populated views or volume images.
/// - note:``VolumePageView`` _could_ be specified by a structured JSON object.
/* Nope. Do the data first:*/


protocol PageDisplayable: Identifiable {
    // ID is already known.
    // ... can you do it with something not far off of the info cards?
    
    
    
}
