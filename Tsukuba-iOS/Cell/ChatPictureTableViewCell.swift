//
//  ChatPictureTableViewCell.swift
//  Tsukuba-iOS
//
//  Created by Meng Li on 2018/06/29.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

protocol ChatPictureTableViewCellDelegate: class {
    func didOpenPicturePreview(index: Int)
}

class ChatPictureTableViewCell: UITableViewCell {
    
    weak var delegate: ChatPictureTableViewCellDelegate?

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(openPicturePreview))
    
    override func awakeFromNib() {
        pictureImageView.addGestureRecognizer(tapGesture)
        pictureImageView.isUserInteractionEnabled = true
    }
    
    @objc private func openPicturePreview() {
        if let delegate = delegate {
            delegate.didOpenPicturePreview(index: tag)
        }
    }
    
    func fill(index: Int, avatar: String, pictureUrl: String, size: CGSize, delegate: ChatPictureTableViewCellDelegate) {
        self.delegate = delegate
        avatarImageView.kf.setImage(with: Config.shared.imageURL(avatar))
        tag = index
        
        let url = Config.shared.imageURL(pictureUrl)
        var plcaeholder: UIImage!
        if size.width > 0 && size.height > 0 {
            let newHeight = size.height / size.width * self.pictureImageView.frame.width
            plcaeholder = resizeImage(image: R.image.chat_picture_lodingGif()!, newWidth: self.pictureImageView.frame.width, newHeight: newHeight)
        } else {
            plcaeholder = resizeImage(image: R.image.chat_picture_lodingGif()!, newWidth: pictureImageView.frame.width)
        }
        pictureImageView.kf.indicatorType = .activity
        pictureImageView.kf.setImage(with: url, placeholder: plcaeholder, options: [.requestModifier(Config.shared.modifier)]) { image, error, cacheType, imageURL in
            if let error = error {
                print("Loaing chat picture error: \(error)")
            }
            if let image = image {
                self.pictureImageView.image = self.resizeImage(image: image, newWidth: self.pictureImageView.frame.width)
            }
        }
    }
    
    func fill(index: Int, avatar: String, pictureImage: UIImage, delegate: ChatPictureTableViewCellDelegate) {
        self.delegate = delegate
        avatarImageView.kf.setImage(with: Config.shared.imageURL(avatar))
        tag = index
        
        pictureImageView.image = resizeImage(image: pictureImage, newWidth: pictureImageView.frame.width)
    }
    
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0)
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    private func resizeImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0)
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}
