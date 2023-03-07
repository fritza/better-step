import Foundation



let p_yyyy_mm_dd: DateFormatter = {
    let retval = DateFormatter()
    retval.dateFormat = "yyyy-MM-dd"
    return retval
}()

let p_yyyy_mm_dd_hm_ss: DateFormatter = {
    let retval = DateFormatter()
    retval.dateFormat = "yyyy-MM-dd_hh:mm:ss"
    return retval
}()


extension Date {
    public var ymd: String {
        p_yyyy_mm_dd.string(from: self)
    }
    public var ymd_hms: String {
        p_yyyy_mm_dd_hm_ss.string(from: self)
    }
}

Date().ymd
Date().ymd_hms

let jsonSource = """
{
    "title": "Nonesuch", "rank": 4
}
"""
let jsonData = jsonSource.data(using: .utf8)!

struct HasUUID: Decodable {
    let uuid = UUID()
    static let decoder = JSONDecoder()
    
    let title           : String
    let rank            : Int
    
    enum CodingKeys: CodingKey {
        case title
        case rank
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        rank  = try container.decode(Int.self   , forKey: .rank )
    }
}

do {
    let huuid = try JSONDecoder().decode(HasUUID.self, from: jsonData)
    dump(huuid)
}
catch {
    print("No:", error)
}
