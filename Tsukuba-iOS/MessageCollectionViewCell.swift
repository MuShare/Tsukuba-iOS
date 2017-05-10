//
//  MessageCollectionViewCell.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 10/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit

class MessageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func fillWithMessage(_ message: Message) {
        self.titleLabel.text = message.title
        self.coverImageView.kf.setImage(with: imageURL(message.cover))
        self.priceLabel.text = "￥\(message.price!)"
    }
    
}
