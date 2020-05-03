//
//  FeedCell.swift
//  RedditFeed
//
//  Created by Pablo Ezequiel Romero Giovannoni on 01/05/2020.
//  Copyright © 2020 Microedition.biz. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var unreadView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unreadView.layer.cornerRadius = unreadView.bounds.size.height / 2
        selectionStyle = .default
    }
    
    func configure(with viewModel: FeedItemViewModelProtocol) {
        detailsLabel.text = viewModel.details
        titleLabel.text = viewModel.title
        commentsLabel.text = viewModel.comments
        unreadView.isHidden = !viewModel.unread
        
        if let thumbnailURL = viewModel.thumbnail {
            thumbnailImageView.isHidden = false
            thumbnailImageView.setImageURL(thumbnailURL)
        } else {
            thumbnailImageView.isHidden = true
            thumbnailImageView.setImageURL(nil)
        }
    }

}
