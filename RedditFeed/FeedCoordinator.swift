//
//  FeedCoordinator.swift
//  RedditFeed
//
//  Created by Pablo Ezequiel Romero Giovannoni on 01/05/2020.
//  Copyright © 2020 Microedition.biz. All rights reserved.
//

import UIKit

class FeedCoordinator: Coordinator {
    typealias Context = FeedViewModelFactory
    let ctx: Context
    
    weak var splitViewController: UISplitViewController!
    weak var feedViewController: FeedViewController!
    weak var feedNavController: UINavigationController!
    weak var feedItemViewController: FeedItemViewController!
    weak var feedItemNavController: UINavigationController!
    
    init(context: Context, splitViewController: UISplitViewController) {
        self.ctx = context
        self.splitViewController = splitViewController
        self.splitViewController.delegate = self
    }
    
    func start(animated: Bool) {
        let storyboard = UIStoryboard(name: "Feed", bundle: nil)
       
        let feedViewController = storyboard.instantiateViewController(identifier: String(describing: FeedViewController.self)) as! FeedViewController
        feedViewController.delegate = self
        feedViewController.viewModel = ctx.newFeedViewModel()
        let feedNavController = UINavigationController(rootViewController: feedViewController)
        
        let feedItemViewController = storyboard.instantiateViewController(identifier: String(describing: FeedItemViewController.self)) as! FeedItemViewController
        feedItemViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        feedItemViewController.navigationItem.leftItemsSupplementBackButton = true
       
        let feedItemNavController = UINavigationController(rootViewController: feedItemViewController)
        
        splitViewController.viewControllers = [feedNavController, feedItemNavController]
        splitViewController.preferredDisplayMode = .allVisible
      
        self.feedViewController = feedViewController
        self.feedNavController = feedNavController
        self.feedItemViewController = feedItemViewController
        self.feedItemNavController = feedItemNavController
    }
    
}

// MARK: -

extension FeedCoordinator: FeedViewControllerDelegate {
    
    func selectAction(viewController: FeedViewController, feedItem: FeedItemViewModelProtocol) {
        feedItemViewController.viewModel = feedItem
        splitViewController.showDetailViewController(feedItemNavController, sender: self)
    }
    
}

// MARK: -

extension FeedCoordinator: UISplitViewControllerDelegate {
        
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return feedItemViewController.viewModel == nil
    }
    
}
