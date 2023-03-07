//
//  ContentView.swift
//  ToyInstructions
//
//  Created by Fritz Anderson on 3/6/23.
//

import SwiftUI



/// This is the container (tab) view.
struct ContentView: View {
    // Not yet in use
    let baseName: String = ""
    let pages: [OnePage]
    init(jsArrayString: String) {
        pages = try! OnePage.from(
            jsonArray: jsArrayString)
    }
    
    var body: some View {
        VStack {
            ForEach(pages) {
                page in
                
            }
            TabView {
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(jsArrayString: both)
    }
}
