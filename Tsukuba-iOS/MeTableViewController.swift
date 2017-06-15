//
//  MeTableViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class MeTableViewController: UITableViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    let user = UserManager.sharedInstance
    var messageSell = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBack()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if user.login {
            updateUserInfo()
            user.pullUser(completion: { (success) in
                if success {
                    if (self.user.contact == "" || self.user.address == "") {
                        self.performSegue(withIdentifier: "profileSegue", sender: self)
                    }
                    self.updateUserInfo()
                }
            })
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.row {
        // Sign in or show profile
        case 1:
            if (user.login) {
                self.performSegue(withIdentifier:"profileSegue", sender: self)
            } else {
                present(UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()!,
                        animated: true, completion: nil)
            }
        // My Posts
        case 3:
            if user.login {
                performSegue(withIdentifier: "myPostsSegue", sender: "")
            } else {
                showLoginAlert()
            }
        default:
            break
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    // MARK: - Action
    @IBAction func logout(_ sender: Any) {
        // Sign out
        let alertController = UIAlertController(title: NSLocalizedString("sign_out_title", comment: ""),
                                                message: NSLocalizedString("sign_out_message", comment: ""),
                                                preferredStyle: .actionSheet)
        alertController.view.tintColor = Color.main
        let logout = UIAlertAction(title: NSLocalizedString("yes_name", comment: ""),
                                   style: .destructive,
                                   handler:
        { (action) in
            self.user.logout()
            self.titleLabel.text = NSLocalizedString("me_title", comment: "")
            self.subtitleLabel.text = NSLocalizedString("me_subtitle", comment: "")
            self.avatarImageView.image = UIImage(named: "me_user")
        })
        
        let cancel = UIAlertAction(title: NSLocalizedString("cancel_name", comment: ""),
                                   style: .cancel,
                                   handler: nil)
        alertController.addAction(logout)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Service
    func updateUserInfo() {
        titleLabel.text = user.name
        avatarImageView.kf.setImage(with: user.avatarURL)
        if user.type == UserTypeEmail {
            subtitleLabel.text = user.identifier
        } else if user.type == UserTypeFacebook {
            subtitleLabel.text = NSLocalizedString("sign_in_facebook", comment: "")
        }
    }
    
}
