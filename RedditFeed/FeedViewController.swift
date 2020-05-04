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

class FeedViewController: UIViewController, MessagePresenter {
    static let loadNextPageViewHeight: CGFloat = 44
    
    @IBOutlet weak var tableView: UITableView!
    weak var loadNextPageView: TableViewLoadNextPageView!
    
    var viewModel: FeedViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    weak var delegate: FeedViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Top", comment: "")
        
        configureLoadNextPageView()
        configureRefreshControl()
        
        viewModel.fetch()
    }

    override func viewWillAppear(_ animated: Bool) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow, let splitViewController = splitViewController, splitViewController.isCollapsed {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        super.viewWillAppear(animated)
    }
    
    fileprivate func configureLoadNextPageView() {
        let loadNextPageView = TableViewLoadNextPageView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: Self.loadNextPageViewHeight))
        loadNextPageView.isAnimating = true
        tableView.tableFooterView = loadNextPageView
        self.loadNextPageView = loadNextPageView
    }
    
    fileprivate func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        
        tableView.refreshControl = refreshControl
    }
    
    fileprivate func updateUI() {
        guard isViewLoaded else { return }
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    @objc func refreshControlAction(_ sender: AnyObject) {
        viewModel.fetch()
    }

}

// MARK: - FeedViewModelDelegate

extension FeedViewController: FeedViewModelDelegate {
    
    func update(viewModel: FeedViewModelProtocol) {
        updateUI()
    }
    
    func updateError(viewModel: FeedViewModelProtocol, error: Error) {
        tableView.refreshControl?.endRefreshing()
        presentAlert(withError: error)
    }
    
}


// MARK: - UITableViewDataSource

extension FeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedCell.self), for: indexPath) as! FeedCell
        let item = viewModel.items[indexPath.row]
        cell.configure(with: item)
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
    }

}

// MARK: - UIScrollViewDelegate

extension FeedViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndScrolling(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrolling(scrollView)
    }
    
    func scrollViewDidEndScrolling(_ scrollView: UIScrollView) {
        let visibleHeight = scrollView.frame.size.height - scrollView.contentInset.bottom
            
        let isLoadNextPageAreaVisible = visibleHeight >= (scrollView.contentSize.height - Self.loadNextPageViewHeight - scrollView.contentOffset.y)
            
        if isLoadNextPageAreaVisible {
            viewModel.fetchNextPage()
        }
    }
    
}

