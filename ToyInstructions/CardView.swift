//
//  CardView.swift
//  ToyInstructions
//
//  Created by Fritz Anderson on 3/6/23.
//

import SwiftUI

/*
 public let title: String
 public let topContent: String
 public let sysImage: String
 public let bottomContent: String

 */

struct CardView: View {
    let pageConfig: InstructionPageSpec
    let pageIndex: UUID
    let buttonAction: () -> Void
    
    init?(pageParams: InstructionPageSpec,
          buttonAction: @escaping () -> Void) {
        pageConfig = pageParams
        pageIndex = pageParams.id
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Group {
                Text(pageConfig.title).font(.largeTitle)
                Spacer()
                Text(pageConfig.topContent)
                Spacer()
            }
            Image(systemName: pageConfig.sysImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
                .foregroundColor(.accentColor)
                .symbolRenderingMode(.hierarchical)
            Spacer()
            Text(pageConfig.bottomContent)
            Spacer()
            Button("Next", action: buttonAction)
        }
    }
}
/*
 If you had a binding for the displayed index,
 */

struct CardView_Previews: PreviewProvider {
    static let oneOnePage: InstructionPageSpec = {
        InstructionPageSpec(id: 1, title: "Preview", top: "This card illustrates text at the top…", image: "globe", bottom: "… and bottom")
    }()
    
    static var previews: some View {
//        NavigationView {
        CardView(pageParams: oneOnePage) {
                print("beep")
            }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Back") { /* do something to go back.*/}
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Next") { /* do something to go back.*/}
                    }
//                }
        }
    }
}
