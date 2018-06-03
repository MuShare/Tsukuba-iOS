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
    
    let appDelagate = UIApplication.shared.delegate as! AppDelegate
    
    private let disposeBag = DisposeBag()
    
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

        RxKeyboard.instance.visibleHeight.drive(onNext: { keyboardVisibleHeight in
            UIView.animate(withDuration: 0.5, animations: {
                self.view.frame = CGRect(x: 0, y: -keyboardVisibleHeight, width: self.view.frame.size.width, height: self.view.frame.size.height)
            })
        }).disposed(by: disposeBag)

        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNewChat), name: .didReceiveNewChat, object: nil)

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
        if let chat = userInfo["chat"] as? Chat {
            insertChats([chat])
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
            UIView.animate(withDuration: 0.5, animations: {
                self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                self.plainTextField.resignFirstResponder()
            })
        }
    }
}
