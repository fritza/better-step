//
//  ForwardBackBar.swift
//  Better Step
//
//  Created by Fritz Anderson on 3/7/22.
//

import SwiftUI

struct ForwardBackBar: View {
    let wantForward: Bool
    let wantBack: Bool
    let action: ((_ goingForward: Bool) -> Void)?

    init(forward: Bool = false,
         back: Bool = false,
         action: ((_ goingForward: Bool)->Void)? = nil) {
        self.wantBack = back
        self.wantForward = forward
        self.action = action
    }

    var body: some View {
        ZStack {
            Color(cgColor: UIColor(white: 0.0, alpha: 0.1).cgColor)
            HStack {
                if wantBack {
                    Button("\(Image(systemName: "arrow.left")) Previous") {
                        action?(false)
                    }
//                    Spacer()
                }
                gearBarItem()
                Spacer()
                if wantForward {
//                    Spacer()
                    Button("Next \(Image(systemName: "arrow.right"))") {
                        action?(true)
                    }
                }
            }
            .padding([.leading, .trailing], 12)
        }
        .background(.regularMaterial)
    }
}

final class GoingForward: CustomStringConvertible {
    init(_ dir: Bool) { going = dir }
    var going: Bool
    var description: String { going ? "up" : "down" }
}

struct ForwardBackBar_Previews: PreviewProvider {
    static var forwardQ = GoingForward(false)
    static var previews: some View {
        VStack {
            Spacer()
            ZStack {
                Color.green
                ForwardBackBar(
                    forward: true,
                    back: true
                ) { dir in forwardQ.going = dir }
            }
            .frame(height: 44)
            Text(
                "clicked: \(forwardQ.description)")
            Spacer()
        }
    }
}
