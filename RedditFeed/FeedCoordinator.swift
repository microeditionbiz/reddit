//
//  FeedCoordinator.swift
//  RedditFeed
//
//  Created by Pablo Ezequiel Romero Giovannoni on 01/05/2020.
//  Copyright © 2020 Microedition.biz. All rights reserved.
//

import UIKit

class FeedCoordinator: Coordinator {
    typealias Context = FeedViewModelFactory & HasRedditDataManager
    let ctx: Context
    
    weak var splitViewController: UISplitViewController!
    weak var feedItemViewController: FeedItemWebViewViewController!
    weak var feedItemNavController: UINavigationController!
    
    var storyboard: UIStoryboard { UIStoryboard(name: "Feed", bundle: nil) }
    
    init(context: Context, splitViewController: UISplitViewController) {
        self.ctx = context
        self.splitViewController = splitViewController
        self.splitViewController.delegate = self
    }
    
    func start(animated: Bool) {
        splitViewController.viewControllers = [
            createFeedVC(),
            createFeedItemVC(withViewModel: nil)
        ]
        splitViewController.preferredDisplayMode = .allVisible
    }

    func createFeedVC() -> UINavigationController {
        let feedViewController = storyboard.instantiateViewController(identifier: String(describing: FeedViewController.self)) as! FeedViewController
        feedViewController.delegate = self
        feedViewController.viewModel = ctx.newFeedViewModel()
        return UINavigationController(rootViewController: feedViewController)
    }
    
    func createFeedItemVC(withViewModel viewModel: FeedItemViewModel?) -> UINavigationController {
        var vc: FeedItemViewControllerProtocol!
        
        if let viewModel = viewModel {
            if viewModel.hasImage {
                vc = storyboard.instantiateViewController(identifier: String(describing: FeedItemImageViewController.self)) as! FeedItemImageViewController
            } else {
                vc = storyboard.instantiateViewController(identifier: String(describing: FeedItemWebViewViewController.self)) as! FeedItemWebViewViewController
            }
            vc.viewModel = viewModel
            vc.delegate = self
        } else {
            vc = storyboard.instantiateViewController(identifier: String(describing: FeedItemEmptyViewController.self)) as! FeedItemEmptyViewController
        }
            
         vc.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
         vc.navigationItem.leftItemsSupplementBackButton = true
        
         return UINavigationController(rootViewController: vc)
     }
    
}

// MARK: -

extension FeedCoordinator: FeedViewControllerDelegate {
    
    func selectAction(viewController: FeedViewController, feedItem: FeedItemViewModel) {
        splitViewController.showDetailViewController(createFeedItemVC(withViewModel: feedItem), sender: self)
    }
    
    func removeAction(viewController: FeedViewController, feedItem: FeedItemViewModel) {
        ctx.dataManager.deleteFeedItem(with: feedItem.identifier)
    }
    
}

extension FeedCoordinator: FeedItemViewControllerDelegate {
    
    func markAsReadAction(viewController: FeedItemViewControllerProtocol, viewModel: FeedItemViewModel) {
        ctx.dataManager.markFeedItemAsRead(with: viewModel.identifier)
    }
    
}

// MARK: -

extension FeedCoordinator: UISplitViewControllerDelegate {
        
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let navController = secondaryViewController as? UINavigationController, let vc = navController.topViewController as? FeedItemViewControllerProtocol else {
            return false
        }
        return vc.viewModel == nil
    }
    
}
