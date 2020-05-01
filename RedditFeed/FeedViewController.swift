//
//  FeedViewController.swift
//  RedditFeed
//
//  Created by Pablo Ezequiel Romero Giovannoni on 01/05/2020.
//  Copyright © 2020 Microedition.biz. All rights reserved.
//

import UIKit

protocol FeedViewControllerDelegate: AnyObject {
    func selectAction(viewController: FeedViewController, feedItem: FeedItemViewModelProtocol)
}

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: FeedViewModelProtocol!
    weak var delegate: FeedViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }

    override func viewWillAppear(_ animated: Bool) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow, let splitViewController = splitViewController, splitViewController.isCollapsed {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        super.viewWillAppear(animated)
    }

}

// MARK: - UITableViewDataSource

extension FeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedCell.self), for: indexPath) as! FeedCell
        cell.textLabel!.text = viewModel.items[indexPath.row].title
        return cell
    }
 
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.row]
        delegate?.selectAction(viewController: self, feedItem: item)
//        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//        controller.navigationItem.leftItemsSupplementBackButton = true
    }

}

