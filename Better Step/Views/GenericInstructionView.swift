//
//  GenericInstructionView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI

// TODO: Yield to InterstitialPageView
//       which has introAbove and introBelow
#warning("Replace with InterstitialPageView")

/// Display a screen containing instructions before and oafter performing an active task in the same phase.
///
/// When the user moves on from this page, it calls a closure provided by the parent, which handles advancing/retreating on the page collection; and exhaustion of the card-view list.
/// - note: `GenericInstructionView` is _not_ concerned in advancing/retreating the enclosing series.
struct GenericInstructionView: View {
    /// The proportion of screen width allowed the SF Symbol image
    private let imageScale: CGFloat = 0.6

    /// The title text content for the page. If `nil`, no title is displayed.
    /// - note: atw this is _not_ to be used as a navigation title.
    let titleText: String?
    
    /// The content of the `Text` to be displayed after the title and before the image.
    let bodyText: String
    
    // TODO:    Can both SF Symbol and asset names be nil?
    //                It would make sense if no image is to be presented.
    /// The name of the SF Symbol image to display in the middle of the screen.
    ///
    /// If `nil`, do not display the symbol image.
    /// - warning: One and only one of `sfBadgeName` and ``assetName`` must be non-nil.
    let sfBadgeName: String?
    
    /// The name of the image asset  to be displayed full-screen.
    ///
    /// If `nil`, do not display the asset image.
    /// - warning: One and only one of ``sfBadgeName`` and `assetName` must be non-nil.
    let assetName: String?
    
    /// The label for the Proceed/Continue button at the bottom of the page.
    /// - note: If no button title is given, the button will not be displayed.
    var proceedTitle: String?
    /// Whether the "proceed" button is to be displayed at all.
    var proceedEnabled: Bool

    // And then we'll have to decide how to handle the "proceed" action
    /// A closure provided by the parent view when the user dismisses the view.
    let proceedClosure: (() -> Void)?

    /// Initialize with values whose signature labels correspond to the properties of this view
    init(titleText: String? = nil,
         bodyText: String,
         sfBadgeName: String,
         proceedTitle: String? = nil,
         proceedEnabled: Bool = true,
         proceedClosure: ( () -> Void)? = nil) {
       ( self.titleText, self.bodyText, self.sfBadgeName,
         self.proceedTitle, self.proceedTitle) =
        ( titleText, bodyText, sfBadgeName, proceedTitle, proceedTitle)
        self.proceedClosure = proceedClosure
        self.proceedEnabled = proceedEnabled
        
        self.assetName = nil
        
    }

    var body: some View {
        GeometryReader {
            proxy in
            HStack {
                Spacer()
                VStack {
//                    Spacer()
                    // Conditionally: The titls
                    if let tText = titleText {
                        Text(tText)
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .tag("title_text")
                    }
                    Spacer()
                    // The SF badge image, if any, to display
                    if let sfBadgeName {
                        Image(systemName: sfBadgeName)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.accentColor)
                            .frame(
                                height: proxy.size.width * imageScale, alignment: .center)
                            .tag("image")
                    }
                    Spacer()
                    // The extended text with the instructional content.
                    Text(bodyText)
                        .font(.title3)
                        .padding()
                        .minimumScaleFactor(/*@START_MENU_TOKEN@*/0.5/*@END_MENU_TOKEN@*/)
                        .tag("body_text")
                    Spacer()
                    // Conditinally, the dismissal button
                    if let proceedTitle {
                        Button(proceedTitle) {
                            proceedClosure?()
                        }
                        .disabled(!proceedEnabled)
                        .tag("continue")
                    }
                }
                Spacer()
            }
        }
        //        .padding()
    }
}

struct GenericInstructionView_Previews: PreviewProvider {
    static var previews: some View {
        GenericInstructionView(
            titleText: "☠️ Survey ☠️",
            bodyText: "REPLACE WITH InterstitialPageView.\n\nJust do what we tell you and nobody gets hurt.",
            sfBadgeName: "trash.slash",
            proceedTitle: "Go!") { // do something
            }
            .padding()
        // No title, no button title.
        GenericInstructionView(
            bodyText: "This view has neither title or action.",
            sfBadgeName: "trash.slash")
    }
}
