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
    var items: [FeedItemViewModel] {get}
    
    func fetch()
    func fetchNextPage()
}

class FeedViewModel: FeedViewModelProtocol  {
    typealias Context = HasRedditDataManager
    let ctx: Context
    
    weak var delegate: FeedViewModelDelegate?
    
    var items: [FeedItemViewModel] = []
    
    var cancellables = Set<AnyCancellable>()
    
    init(context: Context) {
        self.ctx = context
        
        ctx.dataManager.fetchError.sink { [unowned self] error in
            self.delegate?.updateError(viewModel: self, error: error)
        }.store(in: &cancellables)
        
        ctx.dataManager.feedItems.sink { [unowned self] newItems in
            self.items = newItems.map { item in
                return FeedItemViewModel(feedItem: item)
            }
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

struct FeedItemViewModel {
    fileprivate let feedItem: FeedItem
    
    let identifier: String
    let title: String
    let thumbnail: URL?
    let comments: String
    var unread: Bool
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
        
        self.identifier = feedItem.identifier
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

extension FeedItemViewModel: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(unread)
    }
    
    static func == (lhs: FeedItemViewModel, rhs: FeedItemViewModel) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.unread == rhs.unread
    }
    
}
