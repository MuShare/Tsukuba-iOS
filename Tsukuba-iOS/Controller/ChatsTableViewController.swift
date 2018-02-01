//
//  ChatsTableViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 30/01/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

class ChatsTableViewController: UITableViewController {
    
    let user = UserManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        if !user.login {
            showLoginAlert()
        }
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatSegue" {
            
        }
    }

}

extension ChatsTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "receiverIdentifier", for: indexPath) as! ReceiverTableViewCell
        cell.avatarImageView.kf.setImage(with: imageURL(user.avatar))
        cell.nameLabel.text = "Meng Li"
        cell.messageLabel.text = "How are you, I am fine!"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        performSegue(withIdentifier: "chatSegue", sender: self)
    }
    
}
