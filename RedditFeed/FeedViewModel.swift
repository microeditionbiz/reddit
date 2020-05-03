//
//  FeedViewModel.swift
//  RedditFeed
//
//  Created by Pablo Ezequiel Romero Giovannoni on 01/05/2020.
//  Copyright © 2020 Microedition.biz. All rights reserved.
//

import Foundation

protocol FeedViewModelFactory {
    func newFeedViewModel() -> FeedViewModelProtocol
}

extension DependencyContainer: FeedViewModelFactory {
    func newFeedViewModel() -> FeedViewModelProtocol {
        return FeedViewModel(context: self)
    }
}

// MARK: - Feed

protocol FeedViewModelDelegate: AnyObject {
    func update(viewModel: FeedViewModelProtocol)
    func updateError(viewModel: FeedViewModelProtocol, error: Error)
}

protocol FeedViewModelProtocol {
    var delegate: FeedViewModelDelegate? {get set}
    var items: [FeedItemViewModelProtocol] {get set}
    
    func fetch()
    func fetchNextPage()
}

class FeedViewModel: FeedViewModelProtocol  {
    typealias Context = HasAPIService
    let ctx: Context
    
    weak var delegate: FeedViewModelDelegate?
    weak var currentFetchRequest: APIRequestProtocol?
    
    var items: [FeedItemViewModelProtocol] = []
    var afterIdentifier: String?
    
    init(context: Context) {
        self.ctx = context
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
        let endpoint = RedditAPI.Top(afterIdentifier: afterIdentifier)
        currentFetchRequest = ctx.apiService.load(endpoint: endpoint) { result in
            self.currentFetchRequest = nil
            switch result {
            case .success(let response):
                self.afterIdentifier = response.afterIdentifier
                if let newItems = FeedItem.fetchObjects(in: CoreDataManager.viewContex) {
                    self.items = newItems.map(FeedItemViewModel.init)
                } else {
                    self.items.removeAll()
                }
                self.delegate?.update(viewModel: self)
            case .failure(let error):
                self.delegate?.updateError(viewModel: self, error: error)
            }
        }
    }
    
}

// MARK: - Feed Item

protocol FeedItemViewModelProtocol {
    var title: String {get}
    var details: String {get}
    var thumbnail: URL? {get}
    var comments: String {get}
    var unread: Bool {get}
    var mainContent: URL? {get}
    var hasImage: Bool {get}
}

struct FeedItemViewModel: FeedItemViewModelProtocol {
    let feedItem: FeedItem
    
    let title: String
    let thumbnail: URL?
    let comments: String
    let unread: Bool
    let mainContent: URL?
    let hasImage: Bool
    
    var details: String {
        var details = ""
        if let author = feedItem.author {
            details += String(format: "%@ %@", NSLocalizedString("Posted by", comment: ""), author)
        }
        
        if let createdAt = feedItem.createdAt {
            details += " \(createdAt.pastDateDescription)"
        }
        
        return details
    }

    init(feedItem: FeedItem) {
        self.feedItem = feedItem
        
        self.title = feedItem.title ?? ""
        
        if let thumbnail = feedItem.thumbnail, thumbnail.absoluteString.hasPrefix("http") {
            self.thumbnail = thumbnail
        } else {
            self.thumbnail = nil
        }
        
        self.unread = feedItem.unread
        
        self.comments = String(format: "%d %@", feedItem.commentsCount, NSLocalizedString("Comments", comment: ""))
        
        self.mainContent = feedItem.url
        
        if let postHint = feedItem.postHint, postHint == "image" {
            self.hasImage = postHint == "image"
        } else {
            self.hasImage = false
        }
    }

}
