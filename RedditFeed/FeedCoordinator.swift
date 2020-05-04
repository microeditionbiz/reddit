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
    
    func createFeedItemVC(withViewModel viewModel: FeedItemViewModelProtocol?) -> UINavigationController {
        var vc: UIViewController!
        
        if let viewModel = viewModel {
            if viewModel.hasImage {
                let feedItemVC = storyboard.instantiateViewController(identifier: String(describing: FeedItemImageViewController.self)) as! FeedItemImageViewController
                feedItemVC.viewModel = viewModel
                vc = feedItemVC
            } else {
                let feedItemVC = storyboard.instantiateViewController(identifier: String(describing: FeedItemWebViewViewController.self)) as! FeedItemWebViewViewController
                feedItemVC.viewModel = viewModel
                vc = feedItemVC
            }
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
    
    func selectAction(viewController: FeedViewController, feedItem: FeedItemViewModelProtocol) {
        splitViewController.showDetailViewController(createFeedItemVC(withViewModel: feedItem), sender: self)
    }
    
}

// MARK: -

extension FeedCoordinator: UISplitViewControllerDelegate {
        
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let navController = secondaryViewController as? UINavigationController, let _ = navController.topViewController as? FeedItemEmptyViewController else {
            return false
        }
        return true
    }
    
}
