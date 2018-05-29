import Alamofire
import SwiftyUserDefaults
import Starscream

class ChatManager {
    
    typealias ChatCompletion = ((_ success: Bool, _ chats: [Chat], _ message: String?) -> Void)?
    
    var dao: DaoManager!
    var config: Config!
    var socket: WebSocket!
    
    static let shared = ChatManager()
    
    init() {
        dao = DaoManager.shared
        config = Config.shared
        
        var request = URLRequest(url: URL(string: socketUrl + "?token=\(config.token)")!)
        request.timeoutInterval = 5
        
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func sendPlainText(receiver: String, content: String, completion: ChatCompletion) {
        let params: Parameters = [
            "receiver": receiver,
            "content": content
        ]
        
        Alamofire.request(createUrl("api/chat/text"),
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: config.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                let result = response.getResult()
                let chat = self.dao.chatDao.save(result["chat"]);
                chat.room = self.dao.roomDao.saveOrUpdate(result["chat"]["room"])
                chat.room?.lastMessage = content
                chat.content = content
                self.dao.saveContext()
                completion?(true, [chat], nil)
            } else {
                switch response.errorCode() {
                case .sendPlainText:
                    completion?(false, [], R.string.localizable.error_object_id())
                default:
                    completion?(false, [], R.string.localizable.error_unknown())
                }
            }
        }
    }
    
    func syncChat(_ room: Room, completion: ChatCompletion) {
        let params: Parameters = [
            "seq": room.chats
        ]
        Alamofire.request(createUrl("api/chat/list/" + room.rid!),
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: config.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                let result = response.getResult()
                var chats:[Chat] = []
                for object in result["chats"].arrayValue {
                    let chat = self.dao.chatDao.save(object)
                    chat.content = object["content"].stringValue
                    chat.room = room
                    chats.append(chat)
                }
                if (chats.count > 0) {
                    let lastChat = chats[chats.count - 1]
                    room.chats = lastChat.seq
                    room.updateAt = lastChat.createAt
                    room.lastMessage = lastChat.content
                    self.dao.saveContext()
                }
                completion?(true, chats, nil)
            } else {
                switch response.errorCode() {
                default:
                    completion?(false, [], R.string.localizable.error_unknown())
                }
            }
        }
    }
    
    func clearUnread(_ room: Room) {
        // Update global unread.
        config.globalUnread -= Int(room.unread)
        
        // Update room unread.
        room.unread = 0
        self.dao.saveContext()
        
        // Send didUnreadChanged notification.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationType.didUnreadChanged.rawValue),
                                        object: nil,
                                        userInfo: nil)

    }
    
    func roomStatus(completion: ((_ success: Bool) -> Void)?) {
        var url = "api/chat/room/status?"
        for room in self.dao.roomDao.findAll() {
            url.append("rids=" + room.rid! + "&")
        }
    
        Alamofire.request(createUrl(url),
                          method: .get,
                          parameters: nil,
                          encoding: URLEncoding.default,
                          headers: config.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                let result = response.getResult()
                var globalUnread = 0
                
                for object in result["new"].arrayValue {
                    let room = self.dao.roomDao.saveOrUpdate(object)
                    // Set chat - 1 to sync data.
                    room.chats = room.chats - 1
                    room.unread = 1
                    globalUnread += Int(room.unread)
                }
                
                for object in result["exist"].arrayValue {
                    let room = self.dao.roomDao.getByRid(object["rid"].stringValue)
                    if room != nil {
                        room?.lastMessage = object["lastMessage"].stringValue
                        room?.updateAt = NSDate(timeIntervalSince1970: object["updateAt"].doubleValue / 1000)
                        room?.unread = object["chats"].int16Value - room!.chats
                        globalUnread += Int(room!.unread)
                    }
                }
                self.dao.saveContext()
                self.config.globalUnread = globalUnread
                completion?(true)
            } else {
                switch response.errorCode() {
                default:
                    completion?(false)
                }
            }
        }
    }
    
    func clearAll() {
        
    }
    
}

extension ChatManager: WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let e = error as? WSError {
            print("websocket is disconnected: \(e.message)")
        } else if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            socket.connect()
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Received text: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Received data: \(data.count)")
    }
    
}
