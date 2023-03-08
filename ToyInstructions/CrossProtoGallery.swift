//
//  CrossProtoGallery.swift
//  
//
//  Created by Fritz Anderson on 3/7/23.
//

import SwiftUI

struct CrossProtoGallery: View {
    let pageSpecs: [any GalleryCardSpec]
    @State private var selectedPageIndex: Int = 0
    
    // Have an init that will initialize by…
    // flatmapping homogeneous arrays?
//    You'll have to read them all in from their respective sources, whch means you do know what class the specs are.
    // File-by-file, you generate arrays of 1+ card specs.
    
    init(_ specs: [any GalleryCardSpec]) {
        let theFirst = specs.first!
        print(theFirst.id)

        // I hope that doesn't commit me to all runs
        // being the same static type (what I want is
        // to accumulate
        
//        let consolidated = specs.flatMap { $0 }
        pageSpecs = specs
    }
    
//    @ViewBuilder
//    func cardView<T: GalleryCardSpec>(from spec: some T)
//    ->  some T.CardView
////    where T: GalleryCardSpec
//    {
//        try! spec.createView(
//            buttonAction: { print("BEEEP!") }
//        )
//    }

//    @ViewBuilder
    func cardView<T, U>(from spec: T) -> U
    where T: GalleryCardSpec, U == T.CardView
    {
        let r =
        type(of: spec).CardView
            .init(pageParams: spec, action: { print("something") })
        return r!
        //       try! spec.createView {
        //            print("BANG?!")
        //        } as! U
    }
    
    
    
    var body: some View {
        VStack {
            HStack { Text("Left"); Spacer(); Text("Right") }
            Divider()
            TabView(selection: $selectedPageIndex) {
                
                ForEach(self.pageSpecs) { s in
                    cardView(from: s)
                }
                
                
//                ForEach(1..<6) {
//                    n in
//                    Text("Spec title (\(n)) = GRRR")
//                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }
//
//            TabView(selection: $selectedPageIndex) {
//                ForEach(pageSpecs, id:\.id) {
//                    spec in
//                    Text(verbatim: "Spec title = ")
//                }
//            }
//            .tabViewStyle(.page(indexDisplayMode: .always))
//        }
//        .toolbar
//        {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button("Back") { print() }
//            }
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button("Next") { print(); }
//            }
//        }
//
        //                    let prevIndex = selectedPageIndex - 1
        //                        if prevIndex > 0 {
        //                            selectedPageIndex = prevIndex
        //                        }
        //                        let nextIndex = selectedPageIndex + 1
        //                        if nextIndex >= pageSpecs.count {
        //                            selectedPageIndex = nextIndex
        //                        }
        //                    }
        //            }
        //        .toolbar(.visible, for: .navigationBar)
//    }



    
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


let firstSFSRun: [P_OnePage] = {
    do {
        let retval = try P_OnePage.from(jsonArray: both)
        return retval
    } catch {
        print("\(#fileID):\(#line) -> \(error.localizedDescription)")
        fatalError()
    }
}()

let volImageSpec: CrossProtoVolSpec // CrossProtoVolSpec
= {
    do {
        let retval = try CrossProtoVolSpec.fromJSON( sampleVolumeSpec)
        return retval
    } catch {
        print("\(#fileID):\(#line) -> \(error.localizedDescription)")
        fatalError()
    }
}()

//let andFinalSpec: P_OnePage = {
    let andFinalSpec: P_OnePage = {
    do {
        let retval = try P_OnePage.fromJSON(justFirst)
        return retval
    } catch {
        print("\(#fileID):\(#line) -> \(error.localizedDescription)")
        fatalError()
    }
}()

let allSpecs: [any GalleryCardSpec] = {
    let first = firstSFSRun
    let second = [volImageSpec]
    let third = [andFinalSpec]
        
    let anyfirst : [any GalleryCardSpec] = first
    let anysecond: [any GalleryCardSpec] = second
    let anythird: [any GalleryCardSpec] = third
    
    let all: [[any GalleryCardSpec]] = [
        first, second, third
    ]
    let concated: [any GalleryCardSpec] = all.flatMap { $0 }
    return concated
}()


struct CrossProtoGallery_Previews: PreviewProvider {
    static var previews: some View {
        CrossProtoGallery(allSpecs)
    }
}
