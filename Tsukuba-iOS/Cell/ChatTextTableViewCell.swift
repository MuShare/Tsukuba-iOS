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
        
        struct avatar {
            static let width: CGFloat = 40
            static let top: CGFloat = 12
            static let leading: CGFloat = 15
        }

        struct backgroud {
            static let horizontalMargin: CGFloat = 63
            static let topMargin: CGFloat = 12
            static let bottomMargin: CGFloat = 11
        }
        
        struct message {
            static let leadingMargin: CGFloat = 17
            static let trailingMargin: CGFloat = 14
            static let topMargin: CGFloat = 6
            static let bottomMargin: CGFloat = 10
            static let adjustedValue: CGFloat = 12
        }
        
        static let maxMessageWidth = UIScreen.main.bounds.width - 2.0 * Const.backgroud.horizontalMargin
            - Const.message.leadingMargin - Const.message.trailingMargin
        
    }
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.cornerRadius = 5
        return imageView
    }()
    
    private lazy var messageTextView: UITextView = {
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        textView.isSelectable = true
        textView.isEditable = false
        textView.dataDetectorTypes = [.address, .phoneNumber, .link, .calendarEvent]
        return textView
    }()
    
    private lazy var messageBackgroundImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)

        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(avatarImageView)
        addSubview(messageTextView)
        addSubview(messageBackgroundImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fill(with direction: ChatTextCellDirection, avatar: String, message: String) {
        var messageWidth = Const.maxMessageWidth
        if let font = messageTextView.font {
            messageWidth = message.width(with: font) + Const.message.adjustedValue
        }
        switch direction {
        case .send:
            avatarImageView.snp.updateConstraints {
                $0.topMargin.equalTo(Const.avatar.top)
                $0.width.equalTo(Const.avatar.width)
                $0.height.equalTo(Const.avatar.width)
                $0.trailingMargin.equalTo(-Const.avatar.leading)
            }
            
            messageBackgroundImageView.snp.updateConstraints {
                $0.width.equalTo(min(messageWidth, Const.maxMessageWidth) + Const.message.leadingMargin + Const.message.trailingMargin)
                $0.trailingMargin.equalTo(-Const.backgroud.horizontalMargin)
                $0.topMargin.equalTo(Const.backgroud.topMargin)
                $0.bottomMargin.equalTo(-Const.backgroud.bottomMargin)
            }
            
            messageTextView.snp.updateConstraints {
                $0.left.equalTo(messageBackgroundImageView).offset(Const.message.trailingMargin)
                $0.right.equalTo(messageBackgroundImageView).offset(-Const.message.leadingMargin)
                $0.top.equalTo(messageBackgroundImageView).offset(Const.message.topMargin)
                $0.bottom.equalTo(messageBackgroundImageView).offset(-Const.message.bottomMargin)
            }
        case .receive:
            avatarImageView.snp.updateConstraints {
                $0.topMargin.equalTo(Const.avatar.top)
                $0.width.equalTo(Const.avatar.width)
                $0.height.equalTo(Const.avatar.width)
                $0.leadingMargin.equalTo(Const.avatar.leading)
            }
            
            messageBackgroundImageView.snp.updateConstraints {
                $0.width.equalTo(min(messageWidth, Const.maxMessageWidth) + Const.message.leadingMargin + Const.message.trailingMargin)
                $0.leadingMargin.equalTo(Const.backgroud.horizontalMargin)
                $0.topMargin.equalTo(Const.backgroud.topMargin)
                $0.bottomMargin.equalTo(-Const.backgroud.bottomMargin)
            }
            
            messageTextView.snp.updateConstraints {
                $0.left.equalTo(messageBackgroundImageView).offset(Const.message.leadingMargin)
                $0.right.equalTo(messageBackgroundImageView).offset(-Const.message.trailingMargin)
                $0.top.equalTo(messageBackgroundImageView).offset(Const.message.topMargin)
                $0.bottom.equalTo(messageBackgroundImageView).offset(-Const.message.bottomMargin)
            }
        }
        
        avatarImageView.kf.setImage(with: Config.shared.imageURL(avatar))
        messageTextView.attributedText = NSAttributedString(string: message, attributes: [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: .regular)
        ])
        
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
