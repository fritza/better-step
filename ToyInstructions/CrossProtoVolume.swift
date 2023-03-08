//
//  CrossProtoVolume.swift
//  ToyInstructions
//
//  Created by Fritz Anderson on 3/7/23.
//

import SwiftUI


struct CrossProtoVolSpec: GalleryCardSpec {
    typealias CardView = CrossProtoVolume
    public let id = UUID()
    
    let title           : String
    let upperText       : String
    let imageAssetName  : String
    let lowerText       : String
    let ctActionLabel   : String

    enum CodingKeys: CodingKey {
        case title, upperText, imageAssetName, lowerText, ctActionLabel
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}



struct CrossProtoVolume: GalleryCardView {
    typealias Spec = CrossProtoVolSpec
    
    let buttonAction: () -> Void
    let parameters: Spec
    init?(pageParams: CrossProtoVolSpec, action: @escaping () -> Void) {
        self.buttonAction = action
        self.parameters = pageParams
    }
    
    
    var body: some View {
        VStack {
            Text(parameters.title)
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Spacer(minLength: 12.0)
            
            Text(parameters.upperText)
                .font(.title3)
            
            Spacer()
            
            Image(decorative: parameters.imageAssetName)
                .scaledAndTinted()
                .frame(width: 360)
            
            Spacer()
            
            Text(parameters.lowerText)
                .font(.title3)
            Spacer()
            Button(parameters.ctActionLabel) {
                
            }
            .fontWeight(.bold)
        }
        .font(.body)
        .padding()
    }
}

let img_p: CrossProtoVolSpec = {
    do {
        let retval =  try CrossProtoVolSpec.fromJSON(sampleVolumeSpec)
        return retval
    } catch {
        print("image card Failed:", error)
        fatalError()
    }
}()

struct CrossProtoVolume_Previews: PreviewProvider {
    static var previews: some View {
        CrossProtoVolume(pageParams: img_p) {
            print("beep for VolScreen!")
        }
    }
}
