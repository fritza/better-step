//
//  UPLData.swift
//  DataTaskMinimal
//
//  Created by Fritz Anderson on 1/22/23.
//

import Foundation

 let eol = "\r\n"
//let eol = "\n"  // For debugging only.


public func multipartData(fileName: String,
                          content data: Data,
                          boundary: String) throws -> Data {
    //    boundary is in the form "Boundary-{uuid string}}"
    let headData = headWrapper(boundary: boundary, destinationName: fileName)
    let trailData = trailData(boundary: boundary)
    
    var retval = Data()
    retval.append(headData)
    retval.append(data)
    retval.append(eol.data(using: .utf8)!)
    retval.append(trailData)
    
    return retval
}



func headWrapper(boundary: String,
                 destinationName fileName: String) -> Data {
    var retval = ""
    print(
        "--\(boundary)",
        separator: "", terminator: eol, to: &retval)
    print("Content-Disposition: form-data; name=\"file\"; filename=\"",
          fileName, "\"",
          separator: "", terminator: eol, to: &retval)
    print("Content-Type: ", "application/zip",
          separator: "", terminator: eol, to: &retval)
    print("",   // newline
          separator: "", terminator: eol, to: &retval)
    
    guard let headData = retval.data(using: .utf8) else {
        fatalError("Should be able to turn   \"\(retval)\"  into data")
    }
    return headData
}

func trailData(boundary: String) -> Data {
    var retval = ""
    print(
        "--", boundary, "--",
        separator: "", terminator: eol, to: &retval)
    guard let trailData = retval.data(using: .utf8) else {
        fatalError("Should be able to turn   \"\(retval)\"  into data")
    }
    return trailData
}

extension URLResponse {
    public func cliffNotes() -> [(String, String)]?  // [String:String]?
    {
        guard let asHTTP = self as? HTTPURLResponse else { return nil }
        var retval = ["Status Code": String(asHTTP.statusCode)]
        let names = ["Content-Type", "Date", "Content-Encoding" ,"Content-Length"]
        for name in names {
            let value = asHTTP.value(forHTTPHeaderField: name)
            retval[name] = value ?? "N/A"
        }
        
        let pairs = retval.map { k, v in return (k, v) }
        return pairs
    }
}

