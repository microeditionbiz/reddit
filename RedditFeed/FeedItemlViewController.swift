//
//  FeedItemViewController.swift
//  RedditFeed
//
//  Created by Pablo Ezequiel Romero Giovannoni on 01/05/2020.
//  Copyright © 2020 Microedition.biz. All rights reserved.
//

import UIKit

class FeedItemViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    var viewModel: FeedItemViewModelProtocol? {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        guard isViewLoaded else { return }
        detailDescriptionLabel.text = viewModel?.title ?? "Select an item"
    }

}

