import Alamofire
import SwiftyUserDefaults

class ChatManager {
    
    typealias ChatCompletion = ((_ success: Bool, _ chats: [Chat], _ message: String?) -> Void)?
    
    var dao: DaoManager!
    var config: Config!

    static let shared = ChatManager()
    
    init() {
        dao = DaoManager.shared
        config = Config.shared
        
        roomStatus(isLoginCheck: false) { [weak self] success in
            NotificationCenter.default.post(name: .didRoomStatusUpdated, object: self)
        }
    }
    
    func sendPlainText(receiver: String, content: String, completion: ChatCompletion) {
        let params: Parameters = [
            "receiver": receiver,
            "content": content
        ]
        
        Alamofire.request(config.createUrl("api/chat/text"),
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
    
    func syncChat(_ room: Room, completion: ChatCompletion = nil) {
        let params: Parameters = [
            "seq": room.chats
        ]
        Alamofire.request(config.createUrl("api/chat/list/" + room.rid!),
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
        
        // Send didRoomStatusUpdated notification.
        NotificationCenter.default.post(name: .didRoomStatusUpdated, object: nil)

    }
    
    func roomStatus(isLoginCheck: Bool, completion: ((_ success: Bool) -> Void)? = nil) {
        var url = "api/chat/room/status?"
        for room in self.dao.roomDao.findAll() {
            url.append("rids=" + room.rid! + "&")
        }
    
        Alamofire.request(config.createUrl(url),
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
                    if isLoginCheck {
                        room.chats = room.chats - 10
                        if room.chats < 0 {
                            room.chats = 0
                        }
                        room.unread = 0
                    } else {
                        room.chats = room.chats - 1
                        room.unread = 1
                    }
                    globalUnread += Int(room.unread)
                }
                
                for object in result["exist"].arrayValue {
                    if let room = self.dao.roomDao.getByRid(object["rid"].stringValue) {
                        room.lastMessage = object["lastMessage"].stringValue
                        room.updateAt = Date(timeIntervalSince1970: object["updateAt"].doubleValue / 1000)
                        room.unread = object["chats"].int16Value - room.chats
                        room.chats = object["chats"].int16Value
                        globalUnread += Int(room.unread)
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


