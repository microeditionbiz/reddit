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
       
        let pageSize: Int
        let afterIdentifier: String?
        
        let path: String = "/top.json"
        let method: APIHTTPMethod = .GET
        
        var queryParameters: [String : Any]? {
            var q = [String: Any]()
            q["limit"] = pageSize
            q["t"] = "today"
            if let afterIdentifier = afterIdentifier {
                q["after"] = afterIdentifier
            }
            return q
        }
    }
    
}
