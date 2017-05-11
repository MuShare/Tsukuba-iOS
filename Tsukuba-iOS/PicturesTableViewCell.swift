//
//  PicturesTableViewCell.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 11/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import ImageSlideshow

class PicturesTableViewCell: UITableViewCell {

    @IBOutlet weak var picturesImageSlideshow: ImageSlideshow!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var updateAtLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    func fillWithMessage(_ message: Message) {
        // Slide view
        var inputs: [InputSource] = []
        for path in message.paths {
            inputs.append(KingfisherSource(urlString: createUrl(path))!)
        }
        // If message does not contain any picture, set a input using default cover.
        if inputs.count == 0 {
            inputs.append(KingfisherSource(urlString: createUrl(message.cover))!)
        }
        picturesImageSlideshow.setImageInputs(inputs)
        
        // Author info
        avatarImageView.kf.setImage(with: imageURL(message.avatar!))
        nameLabel.text = message.author
        updateAtLabel.text = formatter.string(from: message.updateAt)
        priceLabel.text = "￥\(message.price!)"
    }

}
