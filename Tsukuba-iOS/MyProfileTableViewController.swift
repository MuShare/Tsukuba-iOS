//
//  MyProfileTableViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class MyProfileTableViewController: UITableViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        debugPrint(createUrl(Defaults[.avatar]!))
        if Defaults[.avatar] != nil {
            avatarImageView.kf.setImage(with: URL(string: createUrl(Defaults[.avatar]!)))
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
}
