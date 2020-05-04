//
//  RedditDataManager.swift
//  RedditFeed
//
//  Created by Pablo Ezequiel Romero Giovannoni on 04/05/2020.
//  Copyright © 2020 Microedition.biz. All rights reserved.
//

import Foundation
import Combine

protocol RedditDataManager {
    var feedItems: AnyPublisher<[FeedItem], Never> {get}
    var fetchError: AnyPublisher<Error, Never> {get}

    func deleteFeedItem(with identifier: String)
    func deleteAll()
    func markFeedItem(asRead read: Bool, identifier: String)
    
    func fetch()
    func fetchNextPage()
}

class RedditDataManagerProvider: RedditDataManager {
    fileprivate static let pageSize: Int = 10 // 35
  
    typealias Context = HasAPIService
    private let ctx: Context
    
    private weak var currentFetchRequest: APIRequestProtocol?
    private var afterIdentifier: String?
    
    lazy var feedItems: AnyPublisher<[FeedItem], Never> = {
        return $_feedItems.eraseToAnyPublisher()
    }()
    
    lazy var fetchError: AnyPublisher<Error, Never> = {
        return _fetchError.eraseToAnyPublisher()
    }()
    
    @Published fileprivate var _feedItems: [FeedItem]
    fileprivate let _fetchError: PassthroughSubject<Error, Never>
    
    init(context: Context) {
        self.ctx = context
        self._feedItems = []
        self._fetchError = PassthroughSubject<Error, Never>()
    }
    
    func deleteFeedItem(with identifier: String) {
        
    }
    
    func deleteAll() {
        
    }
    
    func markFeedItem(asRead read: Bool, identifier: String) {
        
    }
    
    func fetch() {
        currentFetchRequest?.cancel()
        fetch(afterIdentifier: nil)
    }
    
    func fetchNextPage() {
        guard currentFetchRequest == nil else { return }
        fetch(afterIdentifier: afterIdentifier)
    }
    
    fileprivate func fetch(afterIdentifier: String?) {
        let endpoint = RedditAPI.Top(pageSize: Self.pageSize, afterIdentifier: afterIdentifier)
        currentFetchRequest = ctx.apiService.load(endpoint: endpoint) { result in
            self.currentFetchRequest = nil
            switch result {
            case .success(let response):
                // We need to fetch NSManagedObjects in the view context
                let newItems = FeedItem.fetchObjects(withObjectIDs: response.managedObjectIDs, in: CoreDataManager.viewContex)
                
                if afterIdentifier == nil {
                    self._feedItems = newItems
                } else {
                    self._feedItems.append(contentsOf: newItems)
                }
                
                self.afterIdentifier = response.afterIdentifier
            case .failure(let error):
                self._fetchError.send(error)
            }
        }
    }
}
