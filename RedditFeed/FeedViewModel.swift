//
//  FeedViewModel.swift
//  RedditFeed
//
//  Created by Pablo Ezequiel Romero Giovannoni on 01/05/2020.
//  Copyright © 2020 Microedition.biz. All rights reserved.
//

import Foundation
import Combine

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
    typealias Context = HasRedditDataManager
    let ctx: Context
    
    weak var delegate: FeedViewModelDelegate?
    
    var items: [FeedItemViewModelProtocol] = []
    
    var cancellables = Set<AnyCancellable>()
    
    init(context: Context) {
        self.ctx = context
        
        ctx.dataManager.fetchError.sink { [unowned self] error in
            self.delegate?.updateError(viewModel: self, error: error)
        }.store(in: &cancellables)
        
        ctx.dataManager.feedItems.sink { [unowned self] newItems in
            self.items = newItems.map(FeedItemViewModel.init)
            self.delegate?.update(viewModel: self)
        }.store(in: &cancellables)
    }
    
    func fetch() {
        ctx.dataManager.fetch()
    }
    
    func fetchNextPage() {
        ctx.dataManager.fetchNextPage()
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
