//
//  ChatsTableViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 30/01/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

class RoomsTableViewController: UITableViewController {
    
    let user = UserManager.sharedInstance
    let dao = DaoManager.sharedInstance
    
    var rooms: [Room] = []
    var selectedRoom: Room!

    override func viewDidLoad() {
        super.viewDidLoad()
        if !user.login {
            showLoginAlert()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveChatNotification), name: NSNotification.Name(rawValue: NotificationType.didReceivedChat.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSyncRoomStatus), name: NSNotification.Name(rawValue: NotificationType.didSyncRoomStatus.rawValue), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rooms = dao.roomDao.findAll()
        tableView.reloadData()
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatSegue" {
            let destination = segue.destination as! ChatViewController
            destination.receiver = User(uid: selectedRoom.receiverId!,
                                        name: selectedRoom.receiverName!,
                                        avatar: selectedRoom.receiverAvatar!)
        }
    }
    
    // MARK: Notification
    func didReceiveChatNotification(_ notification: Notification) {
        navigationItem.title = NSLocalizedString("chats_loading", comment: "")
    }
    
    func didSyncRoomStatus(_ notification: Notification) {
        navigationItem.title = NSLocalizedString("chats_chats", comment: "")
        rooms = dao.roomDao.findAll()
        tableView.reloadData()
    }

}

extension RoomsTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "receiverIdentifier", for: indexPath) as! ReceiverTableViewCell
        cell.fill(rooms[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRoom = rooms[indexPath.row]
        performSegue(withIdentifier: "chatSegue", sender: self)
    }
    
}
