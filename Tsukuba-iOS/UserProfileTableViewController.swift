//
//  UserProfileTableViewController.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 17/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit

class UserProfileTableViewController: UITableViewController {

    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}
