//
//  SocketManager.swift
//  Tsukuba-iOS
//
//  Created by Meng Li on 2018/05/30.
//  Copyright © 2018 MuShare. All rights reserved.
//

import SwiftyJSON
import Starscream

protocol SocketManagerDelegate: class {
    func didReceiveSocketMessage(_ chats: [Chat])
}

class SocketManager {
    
    static let shared = SocketManager()
    
    var socket: WebSocket?
    var dao: DaoManager!
    var config: Config!
    
    weak var delegate: SocketManagerDelegate?
    
    init() {
        dao = DaoManager.shared
        config = Config.shared
        
        UserManager.shared.delegate = self
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
            socket.connect()
        }
    }
    
}

extension SocketManager: WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
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
        
        if reconnect {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                socket.connect()
            }
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        var chats: [Chat] = []
        for object in JSON.init(parseJSON: text).arrayValue {
            guard let room = self.dao.roomDao.getByRid(object["room"]["rid"].stringValue) else {
                return
            }
            let chat = self.dao.chatDao.save(object)
            chat.content = object["content"].stringValue
            chat.room = room
            chats.append(chat)
        }
        self.dao.saveContext()
        delegate?.didReceiveSocketMessage(chats)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Received data: \(data.count)")
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
