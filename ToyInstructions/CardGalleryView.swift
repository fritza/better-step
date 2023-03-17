//
//  CardGalleryView.swift
//  
//
//  Created by Fritz Anderson on 3/6/23.
//

import SwiftUI

struct CardGalleryView: View {
    let pageSpecs: [InstructionPageSpec]
        
    static let uninitializedPageID = UUID()
    @State var selectedPageID = uninitializedPageID
    
    var firstPageID   : UUID {
        pageSpecs[0].id
    }
    var lastPageID    : UUID {
        pageSpecs.last!.id
    }
    
    func pageIDForIndex(_ n: Int) -> UUID {
        precondition(
            (0..<pageSpecs.count).contains(n)
        )
        return pageSpecs[n].id
    }
    
    func indexForPageID(_ ident: UUID) -> Int {
        pageSpecs.firstIndex(where: { $0.id == ident} )!
    }
    
    init(pages: [InstructionPageSpec]) {
        precondition(pages.count > 0, "Attempt to initilize a gallery with no items.")
        pageSpecs = pages
        selectedPageID = pages[0].id
        
        let titles = Set( pageSpecs.map(\.title) )
        assert(titles.count == pageSpecs.count)
    }
    
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
                .disabled(selectedPageID == firstPageID)
                Spacer()
            }.padding()
            
            Divider()
            
            // MARK: TabView
            TabView(selection:
                        //$selectedIndex
                    $selectedPageID
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
            .onAppear {
                assert(!pageSpecs.isEmpty)
                assert(selectedPageID == Self.uninitializedPageID)
                selectedPageID = pageSpecs[0].id
            }
        }
            /*
             .toolbar
             {
             ToolbarItem(placement: .navigationBarLeading) {
             Button("Back", action: {
             retreat()
             })
             .disabled(selectedPageID == firstPageID)
             }
             ToolbarItem(placement: .navigationBarTrailing) {
             Button("Next", action: {
             advance()
             })
             .disabled(selectedPageID == lastPageID)
             }
             }
             }
             .toolbar(.visible, for: .navigationBar)
             */
        }
        
        @discardableResult
        func advance() -> Bool {
            let nextIndex = indexForPageID(selectedPageID) + 1
            guard nextIndex < pageSpecs.count else {
                return false
            }
            selectedPageID = pageIDForIndex(nextIndex)
            //        selectedIndex = nextIndex
            return true
        }
        
        @discardableResult
        func retreat() -> Bool {
            let prevIndex = indexForPageID(selectedPageID) - 1
            guard prevIndex >= 0 else {
                return false
            }
            selectedPageID = pageIDForIndex(prevIndex)
            //        selectedIndex = prevIndex
            return true
        }
    }
    
    struct CardGalleryView_Previews: PreviewProvider {
        static var previews: some View {
            try! CardGalleryView(pageArrayJSON: both)
        }
    }
