//
//  SimplestCard.swift
//  Gallery
//
//  Created by Fritz Anderson on 3/14/23.
//

import SwiftUI

/*  TODO:
    - add the String interpreter (in Better Step) that does line breaks, etc.
    - the Nav View's "< Back" button takes you back to the top level (which is the only NavigationView in the stack).
    - Restrict the image's _height,_ not width.
    - In preview, SimplestCard's "Next" button crashes the app. Investigate.
    DONE - InterCarousel has a (hidden) row of paging pips.
 */



/// View that displays a card from one ``CardContent``
///
/// Generated for the paging `TabView` in ``InterCarousel``
struct SimplestCard: View {
    let cContent: CardContent
    let buttonTapped: () -> Void
    
    init(content: CardContent,
         tapped: @escaping () -> Void) {
        self.cContent = content
        self.buttonTapped = tapped
    }
    
    func displayImage(asset: String?,
                      symbol: String?,
                      height: CGFloat = 220) -> some View {
        let retval: Image
        if let asset {
            retval = Image(decorative: asset)
        }
        else if let symbol {
            retval = Image(systemName: symbol)
        }
        else {
            fatalError()
        }
        
        return retval
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.accentColor)
            .symbolRenderingMode(.hierarchical)

            .frame(height: height)
    }
    
    @ViewBuilder
    func interiorContent() -> some View {
        VStack {
            Spacer()
            Text(cContent.contentAbove.addControlCharacters)

            Spacer(minLength: 40)
            displayImage(asset : cContent.imageAssetName,
                         symbol: cContent.systemImage   )
            Spacer(minLength: 40)
            Text(
                cContent.contentBelow.addControlCharacters
            )
        }
    }
    
    var body: some View {
        VStack {
            Text(cContent.pageTitle)
                .font(.largeTitle)
            Spacer(minLength: 12)
            ScrollView {
                interiorContent()
            }
            Spacer()
            Button(cContent.proceedTitle) {
                buttonTapped()
            }
        }
    }
}

struct SimplestCard_Previews: PreviewProvider {
    static var content: CardContent = {
        do {
            let retval = try CardContent
                .createContents(from: "walk-intro")
            return retval[5]
        }
        catch {
            let rescue = CardContent(
                pageTitle: "Error",
                contentBelow: "Why, I want to know, is this lower text not rendering?",
                contentAbove: error.localizedDescription,
                systemImage: "figure.walk",
                imageFileName: nil,
                proceedTitle: "Continue")
            return rescue
        }
    }()
    
    static var previews: some View {
        VStack {
            SimplestCard(content: content) {
                print("Beep!")
            }
            .frame(width: 320)//, height: 700)
        }
    }
}
