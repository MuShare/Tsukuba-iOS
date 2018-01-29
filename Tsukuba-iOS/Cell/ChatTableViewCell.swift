//
//  ChatTableViewCell.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 29/01/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    func fill(user: User, message: String) {
        avatarImageView.kf.setImage(with: imageURL(user.avatar))
        messageLabel.text = message
    }

}
