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
        let items: [FeedItemViewModelProtocol] = Array(1...10).map({FeedItemViewModel(title: "Items \($0)")})
        return FeedViewModel(items: items)
    }
}

protocol FeedItemViewModelProtocol {
    var title: String {get}
}

protocol FeedViewModelProtocol {
    var items: [FeedItemViewModelProtocol] {get set}
}

struct FeedItemViewModel: FeedItemViewModelProtocol {
    let title: String
}

struct FeedViewModel: FeedViewModelProtocol  {
    var items: [FeedItemViewModelProtocol]
}
