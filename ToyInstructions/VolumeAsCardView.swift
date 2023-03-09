//
//  VolumeAsCardView.swift
//  ToyInstructions
//
//  Created by Fritz Anderson on 3/6/23.
//

import SwiftUI

// TODO: Resolve the conflict in the Usability tree.
extension Image {
    func scaledAndTinted() -> some View {
        self.resizable()
            .scaledToFit()
            .foregroundColor(.accentColor)
            .symbolRenderingMode(.hierarchical)
    }
}

let sampleVolumeSpec = #"""
{
"title"         : "Turn up the volume",
"upperText"     : "To help you complete your walk, you will hear spoken intructions on when to start, and when your walk is done",
"imageAssetName": "loudness",
"lowerText"     : "Make sure the mute switch is in the un-mute (up) position, and the volume is all the way high.",
"ctActionLabel" : "Ready"
}
"""#

let sampleVolumeData = sampleVolumeSpec.data(using: .utf8)!

struct VolumeSpec: Identifiable, Hashable, Decodable {
    // Now that we've gotten into hererogeneous collections, there's no good way to coordinate IDs between them.
    // And they never had to be sorted anyway. Take it in the order it's read, it's not like you're going to shuffle them.
    
    let id = UUID()
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static let decoder = JSONDecoder()
    
    let title           : String
    let upperText       : String
    let imageAssetName  : String
    let lowerText       : String
    let ctActionLabel   : String
    
    enum CodingKeys: CodingKey {
        case title
        case upperText
        case imageAssetName
        case lowerText
        case ctActionLabel
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.upperText = try container.decode(String.self, forKey: .upperText)
        self.imageAssetName = try container.decode(String.self, forKey: .imageAssetName)
        self.lowerText = try container.decode(String.self, forKey: .lowerText)
        self.ctActionLabel = try container.decode(String.self, forKey: .ctActionLabel)
    }
    
    static func from(string: String) throws -> VolumeSpec {
        let jsonData = string.data(using: .utf8)!
        return try decoder.decode(VolumeSpec.self, from: jsonData)
    }
    
    static func from(baseName: String, `extension`: String = "json") throws -> VolumeSpec {
        guard let url = Bundle.main.url(forResource: baseName, withExtension: `extension`)
        else { throw NSError(domain: "VolumeSpecDomain", code: 1,
                             userInfo: [NSLocalizedDescriptionKey: "Could not find “\(baseName).\(`extension`)” in the main bundle."])
        }
        let jsonData = try Data(contentsOf: url)
        return try decoder.decode(VolumeSpec.self, from: jsonData)
    }
}



struct VolumeAsCardView: View {
    let contents: VolumeSpec
    let backClosure: () -> Void
    init(pageSpec: VolumeSpec, buttonAction: @escaping () -> Void) {
        contents = pageSpec
        backClosure = buttonAction
    }
    
    var body: some View {
        VStack {
            Text(contents.title)
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Spacer(minLength: 12.0)
            
            Text(contents.upperText)
                .font(.title3)
            
            Spacer()
            
            Image(decorative: contents.imageAssetName)
                .scaledAndTinted()
                .frame(width: 360)

            Spacer()
            
            Text(contents.lowerText)
                .font(.title3)
            Spacer()
            Button(contents.ctActionLabel, action: backClosure)
            .fontWeight(.bold)
        }
        .font(.body)
        .padding()
    }
}

struct VolumeAsCardView_Previews: PreviewProvider {
    static var previews: some View {
      try! VolumeAsCardView(contents: VolumeSpec.from(string: sampleVolumeSpec))
    }
}
