//
//  ChatTableViewCell.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 29/01/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit
import SnapKit

enum ChatTextCellDirection {
    case send
    case receive
}
class ChatTextTableViewCell: UITableViewCell {
    
    private struct Const {
        struct backgroud {
            static let horizontalMargin: CGFloat = 63
            static let topMargin: CGFloat = 12
            static let bottomMargin: CGFloat = 11
        }
        
        struct message {
            static let leadingMargin: CGFloat = 21
            static let trailingMargin: CGFloat = 14
            static let topMargin: CGFloat = 4
            static let bottomMargin: CGFloat = 12
        }
    }
    
    let maxMessageWidth = UIScreen.main.bounds.width - 2.0 * Const.backgroud.horizontalMargin
        - Const.message.leadingMargin - Const.message.trailingMargin

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageBackgroundImageView: UIImageView!
    
    func fill(with direction: ChatTextCellDirection, avatar: String, message: String) {
        var messageWidth = maxMessageWidth
        if let font = messageTextView.font {
            messageWidth = message.width(with: font)
        }
        switch direction {
        case .send:
            messageBackgroundImageView.snp.makeConstraints {
                $0.leadingMargin.equalTo(Const.backgroud.horizontalMargin + maxMessageWidth - min(messageWidth, maxMessageWidth))
                $0.trailingMargin.equalTo(-Const.backgroud.horizontalMargin)
                $0.topMargin.equalTo(Const.backgroud.topMargin)
                $0.bottomMargin.equalTo(-Const.backgroud.bottomMargin)
            }
            
            messageTextView.snp.makeConstraints {
                $0.left.equalTo(messageBackgroundImageView).offset(Const.message.trailingMargin)
                $0.right.equalTo(messageBackgroundImageView).offset(-Const.message.leadingMargin)
                $0.top.equalTo(messageBackgroundImageView).offset(Const.message.topMargin)
                $0.bottom.equalTo(messageBackgroundImageView).offset(-Const.message.bottomMargin)
            }
        case .receive:
            
            break
        }
        
        
        avatarImageView.kf.setImage(with: Config.shared.imageURL(avatar))
        messageTextView.text = message
        
        
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
