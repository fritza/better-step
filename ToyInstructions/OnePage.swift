//
//  OnePage.swift
//  ToyInstructions
//
//  Created by Fritz Anderson on 3/6/23.
//

import Foundation
import SwiftUI

let both = #"""
 [
 {
 "id": 0, "title": "Start!",
 "sysImage": "hand.wave",
 "topContent": "This space for rent.",
 "bottomContent": "… but we're happy to see you anyway. Please look around and don't forget to sample the shrimp."
 },
 
 {
 "id": 1, "title": "Second Page",
 "sysImage": "envelope.open",
 "topContent": "This space is off the market.\n\nMuch privacy.",
 "bottomContent": "See the friendly greeting? We LIKE you!"
 }
 ]
 """#

protocol GalleryCardSpec: Identifiable, Hashable, Decodable {
    associatedtype CardView: GalleryCardView where CardView.Spec == Self
    // I OON'T CARE whether the spec looks back at the card it creater.
    // Am I right?
//    var card: CardView { get }

    mutating func createView() throws -> CardView
    
    // RELY on the initializer for the adopting type to set id.
    // static func fromJSON(_ json: String) throws -> Self
}

extension GalleryCardSpec {
    mutating func createView(buttonAction: @escaping () -> Void) throws -> CardView {
        // This is all the card viesw needed so far.
        // Can future adopters need more parameters, or
        // do more in this func? Can I rely on never needing
        // protocol-witness dispatch?
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
protocol GalleryCardView: View {
    associatedtype Spec: GalleryCardSpec where Spec.CardView == Self
    
    var buttonAction: () -> Void { get }
    var parameters: Spec { get }
    init?(pageParams: Spec, action: @escaping () -> Void)
}


/// `A Codable`  representation of the contents of a ``CardView``.
///
/// There a number of `static` functions for deriving ``OnePage`` singletons and `Array`s from JSON.
public struct OnePage: Identifiable, Comparable, Hashable, Codable {
    public let title: String
    public let topContent: String
    public let sysImage: String
    public let bottomContent: String
    
    public let id: Int
        
    public init(id: Int,  title: String,
                 top: String, image: String,
                 bottom: String) {
        (self.id, self.title, self.topContent, bottomContent) =
        (id, title, top, bottom)
        sysImage = image
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.id < rhs.id }
}

private let decoder = JSONDecoder()

extension OnePage {
    public static func fromJSON(_ json: String) throws -> OnePage {
        guard let rData = json.data(using: .utf8) else {
            throw NSError(domain: "OnePageDomain", code: 1)
        }
        let retval = try decoder.decode(OnePage.self, from: rData)
        return retval
    }
    
    public static func from(jsonArray: String) throws -> [OnePage] {
        guard let data = jsonArray.data(using: .utf8) else {
            throw NSError(domain: "OnePageDomain",
                          code: 1)
        }
        let decoded = try decoder.decode([OnePage].self, from: data)
        return decoded
    }
    
    public static func fromJSON(_ json: [String]) throws -> [OnePage] {
        let answer =
        try json
            .map { jString in
                guard let rData = jString.data(using: .utf8) else {
                    throw NSError(domain: "OnePageDomain",
                                  code: 1)
                }
                return rData
            }
            .map { data in
                return try decoder.decode(OnePage.self, from: data)
            }
        return answer
    }
}

