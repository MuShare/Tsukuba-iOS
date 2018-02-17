//
//  ChatViewController.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 29/01/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

class ChatViewController: EditingViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plainTextField: UITextField!
    
    let userManager = UserManager.sharedInstance
    let chatManager = ChatManager.sharedInstance
    let dao = DaoManager.sharedInstance
    
    var receiver: User!
    var chats: [Chat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCustomBack()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        
        navigationItem.title = receiver.name
        
        let room = dao.roomDao.getByReceiverId(receiver.uid)
        if room != nil {
            chats = dao.chatDao.findByRoom(room!)
            chatManager.syncChat(room!, completion: { (success, chats, message) in
                self.chats.append(contentsOf: chats)
                self.tableView.reloadData()
            })
        }
        
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

    @IBAction func send(_ sender: Any) {
        let content = plainTextField.text!
        if content == "" {
            return
        }
        plainTextField.text = ""
        plainTextField.resignFirstResponder()
        chatManager.sendPlainText(receiver: receiver.uid, content: content) { (success, chats, message) in
            if (chats.count == 0) {
                return
            }
            self.chats.append(chats[0])
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: self.chats.count - 1, section: 0)],
                                      with: .automatic)
            self.tableView.endUpdates()
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
