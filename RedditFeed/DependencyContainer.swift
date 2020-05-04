//
//  DependencyContainer.swift
//  RedditFeed
//
//  Created by Pablo Ezequiel Romero Giovannoni on 01/05/2020.
//  Copyright © 2020 Microedition.biz. All rights reserved.
//

import UIKit

class DependencyContainer {
    
    lazy var apiService: APIServiceProtocol = {
        return APIService(baseURL: URL(string: "https://www.reddit.com")!)
    }()
    
    lazy var dataManager: RedditDataManager = {
        return RedditDataManagerProvider(context: self)
    }()

    
    init() {
//        RemoteImageViewConfiguration.defaultImage = UIImage(named: "no_user_small")
        RemoteImageViewConfiguration.downloadService = DowloadService()
        CoreDataManager.configure(containerName: "RedditFeed")
    }
}

protocol HasAPIService {
    var apiService: APIServiceProtocol {get}
}

extension DependencyContainer: HasAPIService { }


protocol HasRedditDataManager {
    var dataManager: RedditDataManager {get}
}

extension DependencyContainer: HasRedditDataManager { }
