//
//  FancyPagingView.swift
//  ToyInstructions
//
//  Created by Fritz Anderson on 3/7/23.
//

import Foundation
import SwiftUI

enum PagingErrors: Error {
    case expectedSingleton(String)
    
}

fileprivate let pagingDecoder = JSONDecoder()


// MARK: - PagingView
protocol PagingView: View {
    associatedtype PVInfo: PageViewInfo where PVInfo.ClientView == Self
    
    static func pagingView( from jsonData: Data) throws -> Self
    static func pagingViews(from jsonData: Data) throws -> [Self]
    init(from info: PVInfo) throws
    
    func instantiate() -> PVInfo
    var info: PVInfo! { get set }
    
    func with(info new: PVInfo) -> Self
}

// MARK:  PagingView Defaults
extension PagingView {
    func with(info new: PVInfo) -> Self {
        var mutable = self
        mutable.info = new
        return mutable
    }
}

// MARK: - PageViewInfo
protocol PageViewInfo: Decodable, Identifiable {
    associatedtype ClientView: PagingView where  ClientView.PVInfo == Self
    func instantiate() -> ClientView
    var pView: ClientView! { get set }
    
    
    // constrain the type so the view and info types refer to each other rather tan cascade
    func attach(toView: ClientView)
    func instantiateView() throws -> ClientView
    
    init(fromData data: Data) throws
}

// MARK: PageViewInfo Defaults
extension PageViewInfo {
    mutating func instantiateView() throws -> ClientView {
        var retval = try ClientView(from: self)
            .with(info: self)
        retval.info = self
        pView = retval
        return retval
    }
    
    func forView(_ view: ClientView) -> Self {
        var temp = self
        temp.pView = view
        return temp
    }
    
    static func pagingInfo(from jsonData: Data) throws -> Self {
        let retval = try pagingDecoder.decode(Self.self, from: jsonData)
        return retval
    }
    
    static func pagingInfos(from jsonData: Data) throws -> [Self] {
        do {
            let retval = try pagingDecoder.decode([Self].self, from: jsonData)
            return retval
        } catch {
            throw PagingErrors.expectedSingleton("Singletpon-for-array, probably. \(error.localizedDescription)")
        }
    }
}

