//
//  SurveyView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/19/21.
//

import SwiftUI

let narrativeString = """
This exercise will assess your stride and pace though a short (six-minute) walk. An alarm sound to signal the beginning and the end of the exercise.

Tap “Proceed" when you are ready
"""

struct SurveyView: View {
    private let imageScale: CGFloat = 0.6
    @State private  var isProceeding = false

    var body: some View {
        GeometryReader {
            proxy in
            HStack {
                Spacer()
                VStack() {
                    Text("DASI Survey")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "checkmark.square")
                    // .renderingMode(.template)
                    // why not renderingMode?
                        .resizable()
                        .foregroundColor(.accentColor)
                        .frame(
                            width: proxy.size.width * imageScale,
                            height: proxy.size.width * imageScale, alignment: .center)
                    Spacer()
                    Text(narrativeString)
                        .font(.body)
                    Spacer()

                    if isProceeding {
                        Text("PROCEEDING!")
                    }
                    else {
                        Button("Proceed") {
                            isProceeding.toggle()
                            // navigate to the in-walk view
                        }
                    }
                }
                Spacer()
            }
        }.padding()
            /*
             VStack(alignment: .center) {
             Text("DASI Survey")
             Image(systemName: "figure.walking")
             .frame(width: proxy.size.width*0.8, height: proxy.size.width*0.8, alignment: .center)
             }
             */
    }
}

struct SurveyView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyView()
    }
}
