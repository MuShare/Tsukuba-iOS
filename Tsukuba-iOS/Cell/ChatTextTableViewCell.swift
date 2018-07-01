//
//  ChatTableViewCell.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 29/01/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

class ChatTextTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageBackgroundImageView: UIImageView!
    
    func fill(avatar: String, message: String) {
        avatarImageView.kf.setImage(with: Config.shared.imageURL(avatar))
        messageLabel.text = message
        
        let capInsets = UIEdgeInsetsMake(28, 20, 15, 20)
        switch reuseIdentifier {
        case R.reuseIdentifier.chatSenderIdentifier.identifier:
            messageBackgroundImageView.image = R.image.sender_background()?.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
            messageBackgroundImageView.highlightedImage = R.image.sender_background_highlight()?.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
        case R.reuseIdentifier.chatReceiverIdentifier.identifier:
            messageBackgroundImageView.image = R.image.receiver_background()?.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
            messageBackgroundImageView.highlightedImage = R.image.receiver_background_highlight()?.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
        default:
            break
        }
    }

}
