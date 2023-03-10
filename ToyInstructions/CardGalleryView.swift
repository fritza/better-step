//
//  CardGalleryView.swift
//  
//
//  Created by Fritz Anderson on 3/6/23.
//

import SwiftUI

struct CardGalleryView: View {
    let pageSpecs: [InstructionPageSpec]
    
//    @State var selectedPageID: UUID!
//    {
//        didSet {
//            print("selected ID was\n", oldValue?.uuidString ?? "n/a",
//                  "now\n",
//                  selectedPageID?.uuidString ?? "N/A")
//            print()
//        }
//    }
    
    @State var selectedIndex = 0 {
        didSet {
            print("∆ index from", oldValue, "to", selectedIndex) }
    }
    
    var firstPageID   : UUID {
        pageSpecs[0].id
    }
    var lastPageID    : UUID {
        pageSpecs.last!.id
    }

    init(pages: [InstructionPageSpec]) {
        precondition(pages.count > 0, "Attempt to initilize a gallery with no items.")
        pageSpecs = pages
//        selectedPageID = pages[0].id
        
        let titles = Set( pageSpecs.map(\.title) )
        assert(titles.count == pageSpecs.count)
    }
    /*
    func indexFor(id: UUID) -> Int? {
        pageSpecs.firstIndex(where: {
            $0.id == selectedPageID})
    }
    
    func idForPage(indexed i: Int) -> UUID {
        pageSpecs[i].id
    }
     */
    
    init(pageArrayJSON: String) throws {
        let pages = try InstructionPageSpec.from(jsonArray: pageArrayJSON)
        self.init(pages: pages)
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    retreat()
                })  {
                    Text("< Back").font(.title3)
                }
                .disabled(selectedIndex <= 0)
                Spacer()
            }.padding()
            
            Divider()
            
            TabView(selection: $selectedIndex
                    //                        $selectedPageID
            ) {
                ForEach(pageSpecs, id: \.id) { spec in
                    CardView(pageParams: spec, buttonAction: { advance() }
                    )
                    .tabItem {
                        Text(spec.title)
                    }
                    .tag(spec.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .toolbar
            {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back", action: {
                            retreat()
                    })
                    .disabled(selectedIndex <= 0)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Next", action: {
                        advance()
                    })
                    .disabled(selectedIndex >= (pageSpecs.count - 1))
                }
            }
        }
        .toolbar(.visible, for: .navigationBar)
        .onAppear {
            assert(!pageSpecs.isEmpty)
//            selectedPageID = pageSpecs[0].id
        }
    }
        
    @discardableResult
    func advance() -> Bool {
//        guard selectedPageID != lastPageID else { return false }
//        guard let currentIndex = pageSpecs.firstIndex(where: {
//            $0.id == selectedPageID})
//        else { fatalError() }
        
        let nextIndex = selectedIndex + 1
        guard nextIndex < pageSpecs.count else {
            return false
        }
//        let nextCard = pageSpecs[nextIndex]
//        selectedPageID = nextCard.id
        selectedIndex = nextIndex
        return true
    }
    
    @discardableResult
    func retreat() -> Bool {
        let prevIndex = selectedIndex - 1
        guard prevIndex >= 0 else {
            return false
        }
//        guard selectedPageID != firstPageID else { return false }
//        guard
//        let currentIndex = pageSpecs.firstIndex(where: {
//            $0.id == selectedPageID
//        }) else { fatalError() }
//        selectedPageID = nextCard.id
//        let nextCard = pageSpecs[prevIndex]
        selectedIndex = prevIndex
        return true
    }
}

struct CardGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        try! CardGalleryView(pageArrayJSON: both)
    }
}
