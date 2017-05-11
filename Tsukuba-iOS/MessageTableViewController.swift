

//
//  MessageTableViewController.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 11/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit

class MessageTableViewController: UITableViewController {

    let messageManager = MessageManager.sharedInstance
    var messageId: String!
    var message: Message? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setCustomBack()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        
        messageManager.detail(messageId) { (success, message) in
            if (success) {
                self.message = message!
                self.reloadMessage()
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if message == nil {
            return 0
        }
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "introductionCell", for: indexPath) as! IntroductionTableViewCell
            cell.introductionLabel.text = message!.introduction
            return cell
        default:
            return UITableViewCell()
        }        
    }
    
    func reloadMessage() {
        navigationItem.title = message!.title
        tableView.reloadData()
    }

}
