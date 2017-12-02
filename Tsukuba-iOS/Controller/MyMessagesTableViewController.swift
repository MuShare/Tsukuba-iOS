//
//  MyMessagesTableViewController.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 10/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import ESPullToRefresh

class MyMessagesTableViewController: UITableViewController {
    
    var sell = true
    
    let user = UserManager.sharedInstance
    let messageManager = MessageManager.sharedInstance
    var messages: [Message] = []
    var selectedMessage: Message!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCustomBack()
        
        tableView.es.addPullToRefresh {
            // action to be performed (pull data from some source)
            self.messageManager.loadMyMessage(self.sell) { (success, messages) in
                self.messages = messages
                self.tableView.reloadData()
                self.tableView.es.stopPullToRefresh()
            }
        }
        tableView.es.startPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if messageManager.updated {
            tableView.es.startPullToRefresh()
            messageManager.updated = false
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editMessageSegue" {
            segue.destination.setValue(selectedMessage.mid, forKey: "messageId")
        }
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let identifier = message.enable ? "myMessageCell" : "closedMessageCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MyMessageTableViewCell
        cell.fillWithMessage(message)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMessage = messages[indexPath.row]
        if selectedMessage.enable {
            self.performSegue(withIdentifier: "editMessageSegue", sender: self)
        }
    }

    // MARK: - Action
    @IBAction func createMessage(_ sender: Any) {
        if user.login {
            present(UIStoryboard(name: "Post", bundle: nil).instantiateInitialViewController()!,
                    animated: true, completion: nil)
        } else {
            showLoginAlert()
        }
    }
    
    /**
    @IBAction func changeMessageType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            sell = true
        case 1:
            sell = false
        default:
            break
        }
        tableView.es_startPullToRefresh()
    }
    */
    
}
