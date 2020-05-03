//
//  FeedItemImageViewController.swift
//  RedditFeed
//
//  Created by Pablo Ezequiel Romero Giovannoni on 03/05/2020.
//  Copyright © 2020 Microedition.biz. All rights reserved.
//

import UIKit

class FeedItemImageViewController: UIViewController, MessagePresenter {
    
    @IBOutlet var imageView: UIImageView?
      
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
        title = viewModel?.title
        imageView?.setImageURL(viewModel?.mainContent)
    }
    
    @IBAction func shareButtonTouched(_ sender: UIBarButtonItem) {
        presentActivityViewController()
    }
    
    fileprivate func presentActivityViewController() {
        guard let image = imageView?.image else {
            presentAlert(withMessage: NSLocalizedString("Invalid image", comment: ""))
            return
        }
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(vc, animated: true, completion: nil)
    }
        
}
