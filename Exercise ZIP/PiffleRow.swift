//
//  PiffleRow.swift
//  Exercise ZIP
//
//  Created by Fritz Anderson on 1/10/23.
//

import SwiftUI

extension PiffleRow: Layout {
    func sizeThatFits(proposal: ProposedViewSize,
                      subviews: Subviews,
                      cache: inout ()) -> CGSize {
        var toReturn = CGSize.zero
        for (n, sub) in subviews.enumerated() {
            let subStf = sub.sizeThatFits(.unspecified)
            print("size that fits:", subStf)
            
            toReturn.width  += max(subStf.width, toReturn.width)
            toReturn.height += max(subStf.height, toReturn.height)
            
            if n == 0 {
                let sp = sub.spacing
                    .distance(
                        to: subviews[1].spacing,
                        along: .horizontal)
                toReturn.width += sp
            }
            
            print("size to return", toReturn)
            
        }
//        let totalSpacing = 16.0 * (Double(subviews.count - 1))
//        toReturn.width += totalSpacing
        return toReturn
    }
    /*
     subviews.reduce(CGSize.zero) { result, subview in
     let size = subview.sizeThatFits(.unspecified)
     return CGSize(
     width: max(result.width, size.width),
     height: result.height + size.height)
     }

     */
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var starting = bounds.origin
        // No need to set an initial point, minX, minY are there already
        print("Start =", starting)
        
        let label_0 = subviews[0]
        label_0.place(at: starting, proposal: .unspecified)
        
        starting.x += label_0.dimensions(in: .unspecified).height
        print("after adding 0:", starting)
        // SPACING!
        
        subviews[1].place(at: starting, proposal: .unspecified)
        starting.x += subviews[1].dimensions(in: .unspecified).height
        print("after both:", starting)
    }
    
    
}

struct PiffleRow: View {
    let pifflage: Piffle
    init(_ piffle: Piffle) {
        self.pifflage = piffle
    }
    
    func contentContent() -> String {
        let whole = pifflage.content
        let part = whole.prefix(120)
        return part + "…"
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline,
               spacing: 20) {
            Text(pifflage.name)
                .font(.headline)
            Text("\(contentContent())")
        }
               .padding()
    }
}



struct PiffleRow_Previews: PreviewProvider {
    static let piff: Piffle = {
        let retval = try! Piffle.load(from: "Nonsense.json")
        return retval[0]
    }()
    
    static var previews: some View {
        PiffleRow(piff)
    }
}
