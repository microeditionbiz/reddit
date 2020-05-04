//
//  FeedItemViewControllerProtocol.swift
//  RedditFeed
//
//  Created by Pablo Ezequiel Romero Giovannoni on 04/05/2020.
//  Copyright © 2020 Microedition.biz. All rights reserved.
//

import UIKit

protocol FeedItemViewControllerDelegate: AnyObject {
    func markAsReadAction(viewController: FeedItemViewControllerProtocol, viewModel: FeedItemViewModel)
}

protocol FeedItemViewControllerProtocol: UIViewController {
    var delegate: FeedItemViewControllerDelegate? {get set}
    var viewModel: FeedItemViewModel? {get set}
}

