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
    @IBOutlet weak var messageBackgroundImageView: UIImageView!

    func fill(avatar: String, message: String) {
        var type = ""
        if self.reuseIdentifier == "senderIdentifier" {
            type = "sender"
        } else if self.reuseIdentifier == "receiverIdentifier" {
            type = "receiver"
        }
        messageBackgroundImageView.image = UIImage(named: "\(type)_background")?.resizableImage(withCapInsets: UIEdgeInsetsMake(28, 20, 15, 20), resizingMode: .stretch)
        messageBackgroundImageView.highlightedImage = UIImage(named: "\(type)_background_highlight")?.resizableImage(withCapInsets: UIEdgeInsetsMake(28, 20, 15, 20), resizingMode: .stretch)
        
        avatarImageView.kf.setImage(with: Config.shared.imageURL(avatar))
        messageLabel.text = message
    }

}
