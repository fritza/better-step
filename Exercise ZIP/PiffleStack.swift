//
//  PiffleStack.swift
//  Exercise ZIP
//
//  Created by Fritz Anderson on 1/10/23.
//

import SwiftUI

struct PiffleStack: View {
    let pifflage: Piffle
    init(_ piffle: Piffle) { self.pifflage = piffle}
    
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



struct PiffleStack_Previews: PreviewProvider {
    static let piff: Piffle = {
        let retval = try! Piffle.load(from: "Nonsense.json")
        return retval[0]
    }()
    
    static var previews: some View {
        PiffleStack(piff)
    }
}
