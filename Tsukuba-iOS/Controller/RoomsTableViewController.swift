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
    
    let dao = DaoManager.shared
    let userManager = UserManager.shared
    let chatManager = ChatManager.shared
    
    var rooms: [Room] = []
    var selectedRoom: Room!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if !userManager.login {
            showLoginAlert()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(roomStatusUpdating), name: .roomStatusUpdating, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(roomStatusUpdated), name: .didRoomStatusUpdated, object: nil)
        
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
    @objc func roomStatusUpdating() {
        navigationItem.title = R.string.localizable.chats_loading()
    }
    
    @objc func roomStatusUpdated() {
        navigationItem.title = R.string.localizable.chats_chats()
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
