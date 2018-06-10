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
    
    private struct Const {
        static let toolBarHeight: CGFloat = 50.0
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plainTextField: UITextField!
    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    
    var receiver: User!
    var chats: [Chat] = []
    var room: Room?
    
    let appDelagate = UIApplication.shared.delegate as! AppDelegate
    var viewHeight: CGFloat!
    var keyboardShowing = false

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCustomBack()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        
        navigationItem.title = receiver.name

        room = DaoManager.shared.roomDao.getByReceiverId(receiver.uid)
        if room != nil {
            chats = DaoManager.shared.chatDao.findByRoom(room!)
            ChatManager.shared.syncChat(room!) { [weak self] (success, chats, message) in
                self?.chats.append(contentsOf: chats)
                self?.tableView.reloadData()
                self?.gotoBottom(false)
            }
        }

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(ChatViewController.keyboardWillShow),
                                       name: NSNotification.Name.UIKeyboardWillShow,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(ChatViewController.keyboardWillHide),
                                       name: NSNotification.Name.UIKeyboardWillHide,
                                       object: nil)
        viewHeight = view.frame.size.height - UIApplication.shared.statusBarFrame.size.height - (navigationController?.navigationBar.frame.size.height)!
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNewChat), name: .didReceiveNewChat, object: nil)

    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardShowing {
            return
        }
        keyboardShowing = true
        
        guard let keyboardVisibleHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
            return
        }
        let tableHeight = self.tableView.contentSize.height
        let hiddenHeight = self.viewHeight - Const.toolBarHeight - keyboardVisibleHeight
        
        UIView.animate(withDuration: 0.2) {
            if tableHeight < hiddenHeight {
                self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - keyboardVisibleHeight)
            } else {
                self.view.frame = CGRect(x: 0, y: -keyboardVisibleHeight, width: self.view.frame.size.width, height: self.view.frame.size.height)
                if tableHeight < self.viewHeight - Const.toolBarHeight {
                    self.tableView.frame = CGRect(x: self.tableView.frame.origin.x,
                                                  y: self.tableView.frame.origin.y + self.viewHeight - tableHeight - Const.toolBarHeight,
                                                  width: self.tableView.frame.size.width,
                                                  height: tableHeight)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        keyboardShowing = false
        UIView.animate(withDuration: 0.2) {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: UIScreen.main.bounds.height)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        appDelagate.isChatting = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let room = room {
            ChatManager.shared.clearUnread(room)
        }
        
        tabBarController?.tabBar.isHidden = false
        appDelagate.isChatting = false
    }
    
    private func insertChats(_ chats: [Chat]) {
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
    
    private func gotoBottom(_ animated: Bool) {
        if chats.count > 0 {
            let indexPath = IndexPath(row: chats.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    // MARK: Notification
    @objc func didReceiveNewChat(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        if let chats = userInfo["chats"] as? [Chat] {
            insertChats(chats)
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
        ChatManager.shared.sendPlainText(receiver: receiver.uid, content: content) { [weak self] (success, chats, message) in
            self?.insertChats(chats)
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
        guard let room = chat.room else {
            return UITableViewCell()
        }
        let isSender = room.creator ? chat.direction : !chat.direction
        let identifier = isSender ? "senderIdentifier" : "receiverIdentifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ChatTableViewCell
        cell.fill(avatar: isSender ? UserManager.shared.avatar : room.receiverAvatar!,
                  message: chat.content!)
        return cell
    }
    
}

extension ChatViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -20 {
            self.plainTextField.resignFirstResponder()
        }
    }
    
}
