//
//  ChatTimeTableViewCell.swift
//  Tsukuba-iOS
//
//  Created by mon.ri on 2018/06/27.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

class ChatTimeTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: PaddingLabel!
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    var time: Date? {
        didSet {
            guard let time = time else {
                return
            }
            
            if time.isInToday {
                timeLabel.text = ChatTimeTableViewCell.timeFormatter.string(from: time)
            } else if time.isInYesterday {
                timeLabel.text = "\(R.string.localizable.yesterday_name()) \(ChatTimeTableViewCell.timeFormatter.string(from: time))"
            } else {
                timeLabel.text = ChatTimeTableViewCell.dateFormatter.string(from: time)
            }
        }
    }

}
