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
    var items: [FeedItemViewModelProtocol]
    
    init(context: Context) {
        self.ctx = context
        self.items = []
    }
    
    func fetch() {
        let endpoint = RedditAPI.Top(afterIdentifier: nil, beforeIdentifier: nil)
        ctx.apiService.load(endpoint: endpoint) { result in
            switch result {
            case .success:
                self.items = FeedItem.fetchObjects(in: CoreDataManager.viewContex).map(FeedItemViewModel.init)
                self.delegate?.update(viewModel: self)
            case .failure(let error):
                self.delegate?.updateError(viewModel: self, error: error)
            }
        }
    }
    
    func fetchNextPage() {
        // TODO: implement
    }
}

// MARK: - Feed Item

protocol FeedItemViewModelProtocol {
    var title: String? {get}
    var author: String? {get}
    var entryDate: String? {get}
    var thumbnail: URL? {get}
    var numberOfComments: String {get}
    var unread: Bool {get}
}

struct FeedItemViewModel: FeedItemViewModelProtocol {
    let title: String?
    let author: String?
    let entryDate: String?
    let thumbnail: URL?
    let numberOfComments: String
    let unread: Bool
    
    init(feedItem: FeedItem) {
        self.title = feedItem.title
        self.author = feedItem.author
        self.thumbnail = feedItem.thumbnail
        self.entryDate = feedItem.createdAt?.pastDateDescription
        self.numberOfComments = feedItem.commentsCount == 0 ? "" : "\(feedItem.commentsCount)"
        self.unread = feedItem.unread
    }

}
