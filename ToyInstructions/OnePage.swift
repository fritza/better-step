//
//  OnePage.swift
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


// MARK: - OnePage (spec)
/// `A Codable`  representation of the contents of a ``CardView``.
///
/// There a number of `static` functions for deriving ``OnePage`` singletons and `Array`s from JSON.
public struct OnePage: Identifiable
//, Comparable
, Hashable, Codable {
    public let title: String
    public let topContent: String
    public let sysImage: String
    public let bottomContent: String
    
    enum CodingKeys: CodingKey {
        case title
        case topContent
        case sysImage
        case bottomContent
    }
    
    public let id = UUID()
        
    public init(id: Int,  title: String,
                 top: String, image: String,
                 bottom: String) {
//        (self.id,
         (self.title, self.topContent, bottomContent) =
//        (id,
         (title, top, bottom)
        sysImage = image
    }
    
//    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.id < rhs.id }
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

