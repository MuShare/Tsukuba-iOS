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
        case 1:
            // Sign in or show profile
            self.performSegue(withIdentifier: user.login ? "profileSegue" : "loginSegue", sender: self)
        case 3:
            messageSell = true
            self.performSegue(withIdentifier: "messageSegue", sender: self)
        case 4:
            messageSell = false
            self.performSegue(withIdentifier: "messageSegue", sender: self)
        default:
            break
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "messageSegue" {
            segue.destination.setValue(messageSell, forKey: "sell")
        } 
     }
    
    // MARK: - Action
    @IBAction func logout(_ sender: Any) {
        // Sign out
        let alertController = UIAlertController(title: NSLocalizedString("sign_out_title", comment: ""),
                                                message: NSLocalizedString("sign_out_message", comment: ""),
                                                preferredStyle: .actionSheet)
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
        subtitleLabel.text = user.identifier
        avatarImageView.kf.setImage(with: user.avatarURL)
    }
    
    
}
