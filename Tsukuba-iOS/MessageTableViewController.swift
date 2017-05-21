

//
//  MessageTableViewController.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 11/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import ESPullToRefresh

class MessageTableViewController: UITableViewController {
    
    let messageManager = MessageManager.sharedInstance

    var messageId: String!
    var message: Message? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setCustomBack()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        tableView.es_addPullToRefresh {
            self.messageManager.detail(self.messageId) { (success, message) in
                if (success) {
                    self.message = message!
                    self.navigationItem.title = message!.title
                    self.tableView.reloadData()
                    self.tableView.es_stopPullToRefresh()
                }
            }
        }
        tableView.es_startPullToRefresh()

    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userProfileSegue" {
            segue.destination.setValue(message?.author?.uid, forKey: "uid")
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if message == nil {
            return 0
        }
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return (message?.options.count)!
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if message == nil {
            return 0
        }
        switch indexPath.section {
        case 0:
            return UIScreen.main.bounds.size.width + 45
        case 1:
            return UITableViewAutomaticDimension
        case 2:
            return UITableViewAutomaticDimension
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "picturesCell", for: indexPath) as! PicturesTableViewCell
            cell.fillWithMessage(message!)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath) as! OptionTableViewCell
            cell.fillWithOption((message?.options[indexPath.row])!)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "introductionCell", for: indexPath) as! IntroductionTableViewCell
            cell.introductionLabel.text = message!.introduction
            return cell
        default:
            return UITableViewCell()
        }        
    }

    // MARK: - Action
    @IBAction func showProfile(_ sender: Any) {
        self.performSegue(withIdentifier: "userProfileSegue", sender: self)
    }
    
}
