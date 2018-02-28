//
//  ChatViewController.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 29/01/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChatViewController: EditingViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plainTextField: UITextField!
    
    let userManager = UserManager.sharedInstance
    let chatManager = ChatManager.sharedInstance
    let dao = DaoManager.sharedInstance
    
    var receiver: User!
    var chats: [Chat] = []
    var room: Room?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCustomBack()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        
        navigationItem.title = receiver.name
        
        room = dao.roomDao.getByReceiverId(receiver.uid)
        if room != nil {
            chats = dao.chatDao.findByRoom(room!)
            chatManager.syncChat(room!, completion: { (success, chats, message) in
                self.chats.append(contentsOf: chats)
                self.tableView.reloadData()
                self.gotoBottom(false)
            })
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveChatNotification), name: NSNotification.Name(rawValue: NotificationType.didReceivedChat.rawValue), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        var height = UIScreen.main.bounds.height
        // Adapt the height for iPhone X.
        if UIDevice.current.isX() {
            height += 50
        }
        self.shownHeight = height - 45
    }

    func insertChats(_ chats: [Chat]) {
        if (chats.count == 0) {
            return
        }
        self.chats.append(contentsOf: chats)
        self.tableView.beginUpdates()
        var indexPaths: [IndexPath] = []
        for row in (self.chats.count - chats.count)...(self.chats.count - 1) {
            indexPaths.append(IndexPath(row: row, section: 0))
        }
        self.tableView.insertRows(at: indexPaths, with: .automatic)
        self.tableView.endUpdates()
        self.gotoBottom(true)
    }
    
    func gotoBottom(_ animated: Bool) {
        self.tableView.scrollToRow(at: IndexPath(row: chats.count - 1, section: 0), at: .bottom, animated: animated)
    }
    
    // MARK: Notification
    func didReceiveChatNotification(_ notification: Notification) {
        let receiverId = JSON(notification.userInfo!)["uid"].stringValue
        if receiverId == receiver.uid {
            chatManager.syncChat(room!, completion: { (success, chats, message) in
                self.insertChats(chats)
            })
        }
    }

    // MARK: Action
    @IBAction func send(_ sender: Any) {
        let content = plainTextField.text!
        if content == "" {
            return
        }
        plainTextField.text = ""
        plainTextField.resignFirstResponder()
        chatManager.sendPlainText(receiver: receiver.uid, content: content) { (success, chats, message) in
            self.insertChats(chats)
        }
    }
    
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = chats[indexPath.row]
        let isSender = (chat.room?.creator)! ? chat.direction : !chat.direction
        let identifier = isSender ?  "senderIdentifier" : "receiverIdentifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ChatTableViewCell
        cell.fill(avatar: chat.direction ? userManager.avatar : (chat.room?.receiverAvatar)!,
                  message: chat.content!)
        return cell
    }
}

extension ChatViewController: UITableViewDelegate {
    
}
