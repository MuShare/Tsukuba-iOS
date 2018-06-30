//
//  ChatPictureTableViewCell.swift
//  Tsukuba-iOS
//
//  Created by Meng Li on 2018/06/29.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

class ChatPictureTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    var avatar: String? {
        didSet {
            if let avatar = avatar {
                avatarImageView.kf.setImage(with: Config.shared.imageURL(avatar))
            }
        }
    }
    
    var picture: String? {
        didSet {
            guard let picture = picture else {
                return
            }
            let url = Config.shared.imageURL(picture)
            let plcaeholder = R.image.chat_picture_lodingGif()
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
    }
    
    var pictureImage: UIImage? {
        didSet {
            guard let image = pictureImage else {
                return
            }
            pictureImageView.image = resizeImage(image: image, newWidth: pictureImageView.frame.width)
        }
    }
    
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}
