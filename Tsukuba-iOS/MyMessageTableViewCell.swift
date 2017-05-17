//
//  MyMessageTableViewCell.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 10/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit

class MyMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var updateAtLabel: UILabel!
    
    var closed = false
    
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    func fillWithMessage(_ message: Message) {
        self.titleLabel.text = message.title
        self.coverImageView.kf.setImage(with: imageURL(message.cover))
        self.priceLabel.text = "￥\(message.price!)"
        self.updateAtLabel.text = MyMessageTableViewCell.formatter.string(from: message.updateAt)
        if !message.enable {
            close()
        }
    }
    
    func close() {
        if !closed {
            self.addSubview({
                let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
                view.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5)
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
                label.text = NSLocalizedString("closed_message", comment: "")
                label.textColor = .white
                label.textAlignment = .center
                view.addSubview(label)
                return view
            }())
            closed = true
        }
    }

}
