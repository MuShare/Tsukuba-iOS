//
//  UserProfileTableViewController.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 17/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit

class UserProfileTableViewController: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var createAtLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    let userManager = UserManager.sharedInstance
    
    var uid: String!
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userManager.get(uid) { (success, user) in
            self.loadUser(user!)
        }
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    // MARK: - Service
    func loadUser(_ user: User) {
        navigationItem.title = user.name
        nameLabel.text = user.name
        if user.type == UserTypeEmail {
            emailLabel.text = user.identifier
        } else if user.type == UserTypeFacebook {
            emailLabel.text = NSLocalizedString("sign_in_facebook", comment: "")
        }
        avatarImageView.kf.setImage(with: imageURL(user.avatar))
        createAtLabel.text = formatter.string(from: user.createAt)
        contactLabel.text = user.contact
        addressLabel.text = user.address
    }

}
