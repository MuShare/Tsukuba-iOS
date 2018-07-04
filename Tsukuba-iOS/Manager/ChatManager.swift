import Alamofire
import SwiftyUserDefaults

enum ChatMessageType: Int16 {
    case pictureSending = -1
    case plainText = 0
    case picture = 1
}

class ChatManager {
    
    private struct Const {
        static let pictureMaxWidth: CGFloat = 600
    }
    
    typealias ChatCompletion = ((_ success: Bool, _ chat: Chat?, _ message: String?) -> Void)?
    typealias ChatsCompletion = ((_ success: Bool, _ chats: [Chat], _ message: String?) -> Void)?
    
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
                completion?(true, chat, nil)
            } else {
                switch response.errorCode() {
                case .sendPlainText:
                    completion?(false, nil, R.string.localizable.error_object_id())
                default:
                    completion?(false, nil, R.string.localizable.error_unknown())
                }
            }
        }
    }
    
    func sendPicture(receiver: String, image: UIImage, start:((UIImage?) -> Void)?, completion: ChatCompletion) {
        guard let compressedImage = image.resize(width: Const.pictureMaxWidth),
            let data = UIImageJPEGRepresentation(compressedImage, 1) else {
            completion?(false, nil, R.string.localizable.error_unknown())
            return
        }
        
        start?(compressedImage)
        
        let url = "api/chat/picture?receiver=\(receiver)&width=\(image.size.width)&height=\(image.size.height)"
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data, withName: "picture", fileName: UUID().uuidString, mimeType: "image/jpeg")
        }, usingThreshold: UInt64.init(), to: config.createUrl(url), method: .post, headers: config.tokenHeader, encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress { progress in
                    print(progress)
                }
                upload.responseJSON { responseObject in
                    let response = Response(responseObject)
                    if response.statusOK() {
                        let result = response.getResult()
                        let chatObject = result["chat"]
                        let roomObject = chatObject["room"]
                        
                        let chat = self.dao.chatDao.save(chatObject)
                        chat.room = self.dao.roomDao.saveOrUpdate(roomObject)
                        chat.room?.lastMessage = R.string.localizable.last_message_picture()
                        chat.content = chatObject["content"].stringValue
                        self.dao.saveContext()
                        completion?(true, chat, nil)
                    } else {
                        switch response.errorCode() {
                        default:
                            completion?(false, nil, R.string.localizable.error_unknown())
                        }
                    }
                }
            case .failure(let encodingError):
                if DEBUG {
                    debugPrint(encodingError)
                }
                completion?(false, nil, R.string.localizable.error_unknown())
            }
        })
        
    }
    
    func syncChat(_ room: Room, completion: ChatsCompletion = nil) {
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
                    if self.dao.chatDao.isChatSaved(object["cid"].stringValue) {
                        continue
                    }
                    let chat = self.dao.chatDao.save(object)
                    chat.content = object["content"].stringValue
                    chat.room = room
                    chats.append(chat)
                }
                    
                if (chats.count > 0) {
                    let lastChat = chats[chats.count - 1]
                    room.chats = lastChat.seq
                    room.updateAt = lastChat.createAt
                    switch lastChat.type {
                    case ChatMessageType.plainText.rawValue:
                        room.lastMessage = lastChat.content
                    case ChatMessageType.picture.rawValue:
                        room.lastMessage = R.string.localizable.last_message_picture()
                    default:
                        break
                    }
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
                        let lastMessage = object["lastMessage"].stringValue
                        switch lastMessage {
                        case "[picture]":
                            room.lastMessage = R.string.localizable.last_message_picture()
                        default:
                            room.lastMessage = lastMessage
                        }
                        
                        room.updateAt = Date(timeIntervalSince1970: object["updateAt"].doubleValue / 1000)
                        room.unread = object["chats"].int16Value - room.chats
                        room.chats = object["chats"].int16Value
                        globalUnread += Int(room.unread)
                    }
                }
                self.dao.saveContext()
                self.config.globalUnread = globalUnread
                
                NotificationCenter.default.post(name: .didRoomStatusUpdated, object: self)
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


