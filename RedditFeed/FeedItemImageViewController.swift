//
//  FeedItemImageViewController.swift
//  RedditFeed
//
//  Created by Pablo Ezequiel Romero Giovannoni on 03/05/2020.
//  Copyright © 2020 Microedition.biz. All rights reserved.
//

import UIKit

class FeedItemImageViewController: UIViewController, FeedItemViewControllerProtocol, MessagePresenter {
    
    @IBOutlet var imageView: UIImageView?
      
    weak var delegate: FeedItemViewControllerDelegate?
    
    var viewModel: FeedItemViewModel? {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let viewModel = viewModel else { return }
        delegate?.markAsReadAction(viewController: self, viewModel: viewModel)
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
