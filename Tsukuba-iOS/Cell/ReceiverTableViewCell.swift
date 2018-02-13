//
//  ReceiverTableViewCell.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 30/01/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

class ReceiverTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    let calendar = Calendar.current
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fill(_ room: Room) {
        avatarImageView.kf.setImage(with: imageURL(room.receiverAvatar!))
        nameLabel.text = room.receiverName!
        messageLabel.text = "message"
        let updateAt = room.updateAt as! Date
        if calendar.isDateInToday(updateAt) {
            timeLabel.text = timeFormatter.string(for: updateAt)
        } else if calendar.isDateInYesterday(updateAt) {
            timeLabel.text = "Yesterday"
        } else {
            timeLabel.text = dateFormatter.string(for: updateAt)
        }
        messageLabel.text = room.lastMessage
    }

}
