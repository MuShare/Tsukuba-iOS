//
//  ChatPictureTableViewCell.swift
//  Tsukuba-iOS
//
//  Created by Meng Li on 2018/06/29.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

protocol ChatPictureTableViewCellDelegate: class {
    func didOpenPicturePreview(url: String)
}

class ChatPictureTableViewCell: UITableViewCell {
    
    var url: String? = nil
    weak var delegate: ChatPictureTableViewCellDelegate?

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(openPicturePreview))
    
    override func awakeFromNib() {
        pictureImageView.addGestureRecognizer(tapGesture)
        pictureImageView.isUserInteractionEnabled = true
    }
    
    @objc private func openPicturePreview() {
        if let delegate = delegate, let url = url {
            delegate.didOpenPicturePreview(url: url)
        }
    }
    
    func startLoading() {
        loadingView.isHidden = false
        loadingActivityIndicatorView.startAnimating()
    }
    
    func stopLoading() {
        loadingView.isHidden = true
        loadingActivityIndicatorView.stopAnimating()
    }
    
    func fill(with url: String, size: CGSize, avatar: String, delegate: ChatPictureTableViewCellDelegate) {
        self.delegate = delegate
        self.url = url
        avatarImageView.kf.setImage(with: Config.shared.imageURL(avatar))
        
        var placeholderHeight = pictureImageView.frame.size.width
        if size.width > 0 && size.height > 0 {
            placeholderHeight *= size.height / size.width
        }
        let plcaeholder = UIImage(outerColor: .darkGray,
                                  innerColor: .white,
                                  size: CGSize(width: pictureImageView.frame.size.width, height: placeholderHeight))

        pictureImageView.kf.indicatorType = .activity
        pictureImageView.kf.setImage(with: Config.shared.imageURL(url), placeholder: plcaeholder) { image, error, cacheType, imageURL in
            if let error = error {
                print("Loaing chat picture error: \(error)")
            }
            if let image = image {
                self.pictureImageView.image = image.resize(width: self.pictureImageView.frame.width)
            }
        }
    }
    
    func fillSending(with image: UIImage, avatar: String, delegate: ChatPictureTableViewCellDelegate) {
        self.delegate = delegate
        avatarImageView.kf.setImage(with: Config.shared.imageURL(avatar))

        if let compressedImage = image.resize(width: pictureImageView.frame.width) {
            pictureImageView.image = compressedImage
        }
    }
    
    func sendingFinished(url: String) {
        self.url = url
    }
    
}
