//
//  ChatsTableViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 30/01/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit
import ESPullToRefresh

class RoomsTableViewController: UITableViewController {
    
    let dao = DaoManager.sharedInstance
    let userManager = UserManager.sharedInstance
    let chatManager = ChatManager.sharedInstance
    
    var rooms: [Room] = []
    var selectedRoom: Room!

    override func viewDidLoad() {
        super.viewDidLoad()
        if !userManager.login {
            showLoginAlert()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(roomStatusUpdating), name: NSNotification.Name(rawValue: NotificationType.didReceivedChat.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(roomStatusUpdated), name: NSNotification.Name(rawValue: NotificationType.didSyncRoomStatus.rawValue), object: nil)
        
//        tableView.es.addPullToRefresh {
//            self.roomStatusUpdating()
//            self.chatManager.roomStatus { (success) in
//                if success {
//                    self.roomStatusUpdated()
//                }
//            }
//        }

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
    
    // MARK: Service
    func roomStatusUpdating() {
        navigationItem.title = NSLocalizedString("chats_loading", comment: "")
    }
    
    func roomStatusUpdated() {
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
