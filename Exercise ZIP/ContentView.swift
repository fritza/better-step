//
//  ContentView.swift
//  Exercise ZIP
//
//  Created by Fritz Anderson on 1/10/23.
//

import SwiftUI
import ZIPFoundation


enum PifflErrors: Error {
    case noURL(String)
    case noFile(String)
    case noDecoding(Error)
    case badArchive
    case badData(String)
}


struct Piffle: Codable {
    let name: String
    let content: String
    
    var asData: Data? {
        let retval = content.data(using: .utf8)
        assert(retval != nil)
        return retval
    }
    
    static let decoder = JSONDecoder()
    static func load(from fileName: String) throws -> [Piffle]
    {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            throw PifflErrors.noURL(fileName)
        }
        
        let data = try Data(contentsOf: url)
        let retval = try decoder.decode([Piffle].self, from: data)
        return retval
    }
}



struct ContentView: View {
    @State var piffles: [Piffle]
    @State var error: Error?
    
    init(source: String) {
        do {
            piffles = try Piffle.load(from: source)
        }
        catch {
            piffles = []
            self.error = error
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                Spacer()
                Text(error?.localizedDescription ?? "no error")
                    .font(.title).fontWeight(.heavy)
                    .foregroundColor(.red)
                Spacer()
                ForEach (piffles, id: \.name) {
                    piff in
                    PiffleRow(piff)
                }
                Spacer()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(source: "Nonsense.json")
    }
}
