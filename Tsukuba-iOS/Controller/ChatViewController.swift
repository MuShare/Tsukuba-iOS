//
//  ChatViewController.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 29/01/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit
import SwiftyJSON
import RxKeyboard
import RxSwift

class ChatViewController: EditingViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plainTextField: UITextField!
    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    
    var receiver: User!
    var chats: [Chat] = []
    var room: Room?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCustomBack()
        
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
                if let room = self?.room {
                    ChatManager.shared.clearUnread(room)
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveChatNotification), name: NSNotification.Name(rawValue: NotificationType.didReceivedChat.rawValue), object: nil)

        RxKeyboard.instance.visibleHeight
            .drive(onNext: { keyboardVisibleHeight in
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.frame = CGRect(x: 0, y: -keyboardVisibleHeight, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            })
            .disposed(by: disposeBag)

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
        //self.shownHeight = height - 45
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
            ChatManager.shared.syncChat(room!) { [weak self] (success, chats, message) in
                self?.insertChats(chats)
                if let room = self?.room {
                    ChatManager.shared.clearUnread(room)
                }
            }
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
        let isSender = (chat.room?.creator)! ? chat.direction : !chat.direction
        let identifier = isSender ?  "senderIdentifier" : "receiverIdentifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ChatTableViewCell
        cell.fill(avatar: chat.direction ? (chat.room?.receiverAvatar)! : UserManager.shared.avatar,
                  message: chat.content!)
        return cell
    }
}

extension ChatViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -20 {
            UIView.animate(withDuration: 0.5, animations: {
                self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                self.plainTextField.resignFirstResponder()
            })
        }
    }
}
