//
//  OptionTableViewCell.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 13/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit

class OptionTableViewCell: UITableViewCell {

    @IBOutlet weak var selectionLaebl: UILabel!
    @IBOutlet weak var optionLabel: UILabel!
    
    func fillWithOption(_ option: Option) {
        selectionLaebl.text = option.selection?.name
        optionLabel.text = option.name
    }

}
