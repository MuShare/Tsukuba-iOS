//
//  SocketManager.swift
//  Tsukuba-iOS
//
//  Created by Meng Li on 2018/05/30.
//  Copyright © 2018 MuShare. All rights reserved.
//

import SwiftyJSON
import Starscream
import Alamofire

protocol SocketManagerDelegate: class {
    func socketConecting()
    func scoketConnected()
    func socketDisconnected()
    func didReceiveSocketMessage(_ chats: [Chat])
}

class SocketManager {
    
    static let shared = SocketManager()
    
    var socket: WebSocket?
    var dao: DaoManager
    var config: Config
    var reachabilityManager: NetworkReachabilityManager?
    
    weak var delegate: SocketManagerDelegate?
    
    init() {
        dao = DaoManager.shared
        config = Config.shared
        reachabilityManager = Alamofire.NetworkReachabilityManager(host: config.host)
        reachabilityManager?.listener = { status in
            guard let socket = self.socket else {
                return
            }
            switch status {
            case .notReachable:
                print("The network is not reachable")
                socket.disconnect()
            case .unknown :
                print("It is unknown whether the network is reachable")
                
            case .reachable(.ethernetOrWiFi):
                print("The network is reachable over the WiFi connection")
                if !socket.isConnected {
                    self.connectSocket()
                }
            case .reachable(.wwan):
                print("The network is reachable over the WWAN connection")
                if !socket.isConnected {
                    self.connectSocket()
                }
            }
        }

        UserManager.shared.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    func refreshSocket() {
        if config.token == "" {
            print("Web socket has not been conncted due to empty token.")
            return
        }
        var request = URLRequest(url: URL(string: config.socketUrl + "?token=\(config.token)")!)
        request.timeoutInterval = 5
        
        socket = WebSocket(request: request)
        if let socket = socket {
            socket.delegate = self
            connectSocket()
        }
        
        reachabilityManager?.startListening()
    }
    
    func connectSocket() {
        if let socket = socket, let delegate = delegate {
            delegate.socketConecting()
            socket.connect()
        }
    }
    
    // MARK: - Notification
    @objc func applicationDidBecomeActive() {
        guard let socket = socket else {
            return
        }
        if !socket.isConnected {
            connectSocket()
        }
    }
    
    @objc func applicationDidEnterBackground() {
        guard let socket = socket else {
            return
        }
        if socket.isConnected {
            socket.disconnect()
        }
    }
    
}

extension SocketManager: WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
        delegate?.scoketConnected()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        var reconnect = true
        if let error = error as? WSError {
            print("websocket is disconnected: \(error)")

            if error.code == 1003 && error.message == "auth_failed" {
                reconnect = false
            }
        } else if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
        
        delegate?.socketDisconnected()
        
        if reconnect {
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                guard let socket = self.socket, let reachabilityManager = self.reachabilityManager else {
                    return
                }
                if !socket.isConnected && reachabilityManager.isReachable {
                    self.connectSocket()
                }
            }
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        let array = JSON.init(parseJSON: text).arrayValue
        if DEBUG {
            print("did received web socket messages: \(array)")
        }
        
        var chats: [Chat] = []
        for object in array {
            if self.dao.chatDao.isChatSaved(object["cid"].stringValue) {
                continue
            }
            let chat = self.dao.chatDao.save(object)
            
            chat.content = object["content"].stringValue
            chat.room = self.dao.roomDao.getByRid(object["room"]["rid"].stringValue) ??
                self.dao.roomDao.saveOrUpdate(object["room"])
            if let room = chat.room {
                room.chats = chat.seq
                room.unread += 1
                switch chat.type {
                case ChatMessageType.plainText.rawValue:
                    room.lastMessage = chat.content
                case ChatMessageType.picture.rawValue:
                    room.lastMessage = R.string.localizable.last_message_picture()
                default:
                    break
                }
            }
            chats.append(chat)
            config.globalUnread += 1
        }
        self.dao.saveContext()
        
        delegate?.didReceiveSocketMessage(chats)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        if DEBUG {
            print("Received data: \(data.count)")
        }
    }
    
}

extension SocketManager: UserManagerDelegate {
    
    func didUserLogin(_ type: UserType) {
        refreshSocket()
    }
    
    func didUserLogout() {
        if let socket = socket {
            socket.disconnect()
        }
        socket = nil
    }
    
}
