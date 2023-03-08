//
//  GalleryCardProtocols.swift
//  ToyInstructions
//
//  Created by Fritz Anderson on 3/7/23.
//

import Foundation
import SwiftUI


private let decoder = JSONDecoder()

struct IdentifiableAny<T: GalleryCardSpec>: Identifiable {
    var content: T
    var id: T.ID { content.id }
    
    init(_ toWrap: T) { content = toWrap }
}



// MARK: - GalleryCardSpec
protocol GalleryCardSpec: Identifiable, Hashable, Decodable where ID == UUID {
    associatedtype CardView: GalleryCardView where CardView.Spec == Self
}

// MARK: GalleryCardSpec extension
extension GalleryCardSpec {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func createView(buttonAction: @escaping () -> Void) throws -> some GalleryCardView {
        let optView  = CardView(pageParams: self, action: buttonAction)
        precondition(optView != nil, "Shouldn't fail GalleryCardSpec -> createView()")
        return optView!
    }
    
    public static func fromJSON(_ json: String) throws -> Self {
        guard let rData = json.data(using: .utf8) else {
            throw NSError(domain: "OnePageDomain", code: 1)
        }
        let retval = try decoder.decode(Self.self, from: rData)
        return retval
    }
    
    public static func from(jsonArray: String) throws -> [Self] {
        guard let data = jsonArray.data(using: .utf8) else {
            throw NSError(domain: "OnePageDomain",
                          code: 1)
        }
        let decoded = try decoder.decode([Self].self, from: data)
        return decoded
    }
}

// FIXME: Remove "import SwiftUI" after moving this out.
// MARK: - GalleryCardView
protocol GalleryCardView: View {
    associatedtype Spec: GalleryCardSpec where Spec.CardView == Self
    
    var buttonAction: () -> Void { get }
    var parameters: Spec { get }
    init?(pageParams: Spec, action: @escaping () -> Void)
}


public struct P_OnePage: GalleryCardSpec {
    typealias CardView = P_CardView
    public let id = UUID()
    
    public let title: String
    public let topContent: String
    public let sysImage: String
    public let bottomContent: String
    enum CodingKeys: CodingKey {
        case title, topContent, sysImage, bottomContent
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

let one_P: P_OnePage = {
    do {
        let retval = try P_OnePage.fromJSON(justFirst)
        return retval
    } catch {
        print("Failed:", error)
        fatalError()
    }
}()

public struct P_CardView: GalleryCardView {
    //    typealias Spec = P_OnePage
    
    let buttonAction: () -> Void
    let parameters: P_OnePage
    
    init?(pageParams: P_OnePage, action: @escaping () -> Void) {
        self.parameters = pageParams
        self.buttonAction = action
    }
    
    public var body: some View {
        VStack(alignment: .center) {
            Group {
                Text(parameters.title).font(.largeTitle)
                Spacer()
                Text(parameters.topContent)
                Spacer()
            }
            Image(systemName: parameters.sysImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
                .foregroundColor(.accentColor)
                .symbolRenderingMode(.hierarchical)
            Spacer()
            Text(parameters.bottomContent)
            Spacer()
            Button("Next", action: buttonAction)
        }
        
    }
}

struct P_CardView_Previews: PreviewProvider {
    static var previews: some View {
        P_CardView(pageParams: one_P) {
            print("Beep")
        }
    }
}
