//
//  ChatsTableViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 30/01/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit
import ESPullToRefresh

class RoomsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
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
        
        tableView.hideFooterView()
        
        if !userManager.login {
            showLoginAlert()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(connecting), name: .webSocketConnecting, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connected), name: .didWebSocketConnected, object: nil)
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
    
    // MARK: Service
    @objc func connecting() {
        navigationItem.title = R.string.localizable.chats_loading()
    }
    
    @objc func connected() {
        navigationItem.title = R.string.localizable.chats_chats()
    }
    
    @objc func roomStatusUpdated() {
        rooms = dao.roomDao.findAll()
        tableView.reloadData()
    }

}

extension RoomsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.roomIdentifier.identifier, for: indexPath) as! ReceiverTableViewCell
        cell.room = rooms[indexPath.row]
        return cell
    }
    
}

extension RoomsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = rooms[indexPath.row]
        if let chatViewController = R.storyboard.chat.chatViewController() {
            chatViewController.receiver = User(uid: room.receiverId!,
                                               name: room.receiverName!,
                                               avatar: room.receiverAvatar!)
            navigationController?.pushViewController(chatViewController, animated: true)
        }
    }
    
}
