//
//  RedditAPI.swift
//  RedditFeed
//
//  Created by Pablo Ezequiel Romero Giovannoni on 03/05/2020.
//  Copyright © 2020 Microedition.biz. All rights reserved.
//

import Foundation

enum RedditAPI {
    
    struct Top: APIEndpoint {
        typealias ResultType = TopResponse
       
        static let pageSize: Int = 35
        
        let afterIdentifier: String?
        
        let path: String = "/top.json"
        let method: APIHTTPMethod = .GET
        
        var queryParameters: [String : Any]? {
            var q = [String: Any]()
            q["limit"] = Self.pageSize
            if let afterIdentifier = afterIdentifier {
                q["after"] = afterIdentifier
            }
//            q["limit"] = Self.pageSize
//            q["count"] = 0
//            q["t"] = "day"
//            q["inc"] = inc
            return q
        }
    }
    
}
