//
//  FeedViewController.swift
//  RedditFeed
//
//  Created by Pablo Ezequiel Romero Giovannoni on 01/05/2020.
//  Copyright © 2020 Microedition.biz. All rights reserved.
//

import UIKit

protocol FeedViewControllerDelegate: AnyObject {
    func selectAction(viewController: FeedViewController, feedItem: FeedItemViewModel)
    func removeAction(viewController: FeedViewController, feedItem: FeedItemViewModel)
}

class FeedViewController: UIViewController, MessagePresenter {
    
    static let loadNextPageViewHeight: CGFloat = 44
    
    @IBOutlet weak var tableView: UITableView!
    weak var loadNextPageView: TableViewLoadNextPageView!
    weak var delegate: FeedViewControllerDelegate?
    
    var viewModel: FeedViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    var dataSource: FeedDiffableDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Top", comment: "")
        
        configureDataSource()
        configureLoadNextPageView()
        configureRefreshControl()
        
        updateUI()
        viewModel.fetch()
    }
    
    fileprivate func configureDataSource() {
        let removeAction: FeedDiffableDataSource.RemoveAction = { [unowned self] indexPath in
            let feedItem = self.viewModel.items[indexPath.row]
            self.delegate?.removeAction(viewController: self, feedItem: feedItem)
        }
        self.dataSource = FeedDiffableDataSource(tableView: tableView, removeAction: removeAction)
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
        dataSource.update(items: viewModel.items)
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


// MARK: - UITableViewDiffableDataSource

class FeedDiffableDataSource: UITableViewDiffableDataSource<FeedDiffableDataSource.Section, FeedItemViewModel> {
    
    enum Section: CaseIterable {
        case main
    }
    
    typealias RemoveAction = (IndexPath)->()
    let removeAction: RemoveAction
    
    init(tableView: UITableView, removeAction: @escaping RemoveAction) {
        self.removeAction = removeAction
        
        super.init(tableView: tableView) { tableView, indexPath, feedItem in
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedCell.self), for: indexPath) as! FeedCell
            cell.configure(with: feedItem)
            return cell
        }
        
        defaultRowAnimation = .fade
    }
    
    func update(items: [FeedItemViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, FeedItemViewModel>()
         snapshot.appendSections([.main])
         snapshot.appendItems(items, toSection: .main)
         self.apply(snapshot, animatingDifferences: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeAction(indexPath)
        }
    }
    
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feedItem = viewModel.items[indexPath.row]
        delegate?.selectAction(viewController: self, feedItem: feedItem)
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

