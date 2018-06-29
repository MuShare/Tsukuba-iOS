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
            if let picture = picture {
                pictureImageView.kf.setImage(with: Config.shared.imageURL(picture))
            }
        }
    }
    
    var pictureImage: UIImage? {
        didSet {
            guard let image = pictureImage else {
                return
            }
            print(image.size)
            pictureImageView.image = image

        }
    }
    
}
