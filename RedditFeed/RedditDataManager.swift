//
//  RedditDataManager.swift
//  RedditFeed
//
//  Created by Pablo Ezequiel Romero Giovannoni on 04/05/2020.
//  Copyright © 2020 Microedition.biz. All rights reserved.
//

import Foundation
import CoreData
import Combine

protocol RedditDataManager {
    var feedItems: AnyPublisher<[FeedItem], Never> {get}
    var fetchError: AnyPublisher<Error, Never> {get}

    func deleteFeedItem(with identifier: String)
    func markFeedItemAsRead(with identifier: String)
    
    func fetch()
    func fetchNextPage()
}

class RedditDataManagerProvider: RedditDataManager {
    fileprivate static let pageSize: Int = 35
  
    typealias Context = HasAPIService
    private let ctx: Context
    
    private weak var currentFetchRequest: APIRequestProtocol?
    private var afterIdentifier: String?
    
    lazy var feedItems: AnyPublisher<[FeedItem], Never> = {
        return _feedItems.eraseToAnyPublisher()
    }()
    
    fileprivate let _feedItems: CurrentValueSubject<[FeedItem], Never>
      
    lazy var fetchError: AnyPublisher<Error, Never> = {
        return _fetchError.eraseToAnyPublisher()
    }()
    
    fileprivate let _fetchError: PassthroughSubject<Error, Never>

    init(context: Context) {
        self.ctx = context
        self._feedItems = CurrentValueSubject([])
        self._fetchError = PassthroughSubject<Error, Never>()
    }
    
    func deleteFeedItem(with identifier: String) {
        guard let index = _feedItems.value.firstIndex(where: {$0.identifier == identifier}), !_feedItems.value[index].removed else { return }
    
        let feedItem = _feedItems.value[index]
        feedItem.removed = true
        feedItem.save()
        
        _feedItems.value.remove(at: index)
    }
    
    func markFeedItemAsRead(with identifier: String) {
        guard let index = _feedItems.value.firstIndex(where: {$0.identifier == identifier}), _feedItems.value[index].unread else { return }
           
        let feedItem = _feedItems.value[index]
        feedItem.unread = false
        feedItem.save()
        
        _feedItems.value[index] = feedItem
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
                self.afterIdentifier = response.afterIdentifier
                self.processFeedItems(response.managedObjectIDs, append: afterIdentifier != nil)
            case .failure(let error):
                self._fetchError.send(error)
            }
        }
    }
    
    fileprivate func processFeedItems(_ managedObjectIDs: [NSManagedObjectID], append: Bool) {
        // We need to fetch NSManagedObjects in the view context
        let newItems: [FeedItem] = FeedItem.fetchObjects(withObjectIDs: managedObjectIDs, in: CoreDataManager.viewContex).filter({!$0.removed})
        
        if newItems.isEmpty {
            // if all items where deleted we will request next page.
            // This logic is really bad, the items have to be deleted at
            // the API level to avoid this.
            DispatchQueue.main.async {
                self.fetchNextPage()
            }
        } else {
            if !append {
                self._feedItems.value = newItems
            } else {
                // Before adding new items we have to check if the items is
                // already in the list. This may happen when an item that is
                // visible, changed its current position and now it's
                // visible on the second page
                let identifiers = Set(newItems.map(\.identifier))
                              
                let updatedFeedItems = self._feedItems.value.filter({!identifiers.contains($0.identifier)}) + newItems
                  
                self._feedItems.value = updatedFeedItems
            }
        }
    }
}
