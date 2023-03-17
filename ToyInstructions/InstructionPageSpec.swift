//
//  InstructionPageSpec.swift
//  ToyInstructions
//
//  Created by Fritz Anderson on 3/6/23.
//

import Foundation

let justFirst = #"""
 {
 "id": 0, "title": "Start!",
 "sysImage": "hand.wave",
 "topContent": "This space for rent.",
 "bottomContent": "… but we're happy to see you anyway. Please look around and don't forget to sample the shrimp."
 }
 """#

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


// MARK: - InstructionPageSpec (spec)
/// `A Codable`  representation of the contents of a ``CardView``.
///
/// There are a number of `static` functions for deriving ``InstructionPageSpec`` singletons and `Array`s from JSON.
public final class InstructionPageSpec: Identifiable, Hashable, Codable {
    public let title: String
    public let contentAbove: String
    
    public let imageAssetName: String?
    public let sysImage      : String?
    
    public let contentBelow: String
    
    enum CodingKeys: CodingKey {
        case title
        case topContent
        case sysImage
        case bottomContent
    }
    
    public let id = UUID()
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public static func == (
        lhs: InstructionPageSpec,
        rhs: InstructionPageSpec) -> Bool
    { lhs.id == rhs.id }
    
        
    public init(id: Int,  title: String,
                 top: String, image: String,
                 bottom: String) {
//        (self.id,
        (self.title, self.topContent, self.bottomContent) =
//        (id,
         (title, top, bottom)
        sysImage = image
    }
}

private let decoder = JSONDecoder()

extension InstructionPageSpec {
    public static func fromJSON(_ json: String) throws -> InstructionPageSpec {
        guard let rData = json.data(using: .utf8) else {
            throw NSError(domain: "OnePageDomain", code: 1)
        }
        let retval = try decoder.decode(InstructionPageSpec.self, from: rData)
        return retval
    }
    
    public static func from(jsonArray: String) throws -> [InstructionPageSpec] {
        guard let data = jsonArray.data(using: .utf8) else {
            throw NSError(domain: "OnePageDomain",
                          code: 1)
        }
        let decoded = try decoder.decode([InstructionPageSpec].self, from: data)
        return decoded
    }
    
    public static func fromJSON(_ json: [String]) throws -> [InstructionPageSpec] {
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
                return try decoder.decode(InstructionPageSpec.self, from: data)
            }
        return answer
    }
}

