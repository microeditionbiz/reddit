//
//  RedditModel.swift
//  RedditFeed
//
//  Created by Pablo Ezequiel Romero Giovannoni on 03/05/2020.
//  Copyright © 2020 Microedition.biz. All rights reserved.
//

import Foundation
import CoreData

typealias Payload = [String: Any]
typealias List = [Payload]

struct TopResponse: APIResponseBase {
    init(_ data: Data) throws {
        guard let payload = try JSONSerialization.jsonObject(with: data) as? Payload , let dataPayload = payload["data"] as? Payload, let childrenList = dataPayload["children"] as? List else {
            throw APIServiceError.invalidData
        }
        
        let context = CoreDataManager.newBackgroundContext()
        childrenList.forEach { childPayload in
            if let childDataPayload = childPayload["data"] as? Payload {
                FeedItem.object(form: childDataPayload, in: context)
            }
        }
        
        CoreDataManager.save(context: context)
    }
}

extension FeedItem: NSManagedObjectDictionaryMapping {
    
    static func objectIDKeys() -> [String] {
        return ["identifier"]
    }
    
    static func dictionaryIDKeys() -> [String] {
        return ["name"]
    }
 
    func update(with dictionary: [String: Any]) {
        self.title = dictionary["title"] as? String
        self.author = dictionary["author"] as? String
        self.commentsCount = dictionary["num_comments"] as? Int64 ?? 0
        
        if let createdTimeInterval = dictionary["created_utc"] as? TimeInterval {
            self.createdAt = Date(timeIntervalSince1970: createdTimeInterval)
        } else {
            self.createdAt = nil
        }
        
        if let identifier = dictionary["id"] as? String {
            self.identifier = identifier
        } else {
            assertionFailure("Item without identifier")
            self.identifier = ""
        }
        
        if let thumbnailString = dictionary["thumbnail"] as? String {
            self.thumbnail = URL(string: thumbnailString)
        } else {
            self.thumbnail = nil
        }
        
        if let urlString = dictionary["url"] as? String {
            self.url = URL(string: urlString)
        } else {
            self.url = nil
        }
        
        self.postHint = dictionary["post_hint"] as? String
    }
    
}
