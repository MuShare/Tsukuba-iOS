import Alamofire
import SwiftyUserDefaults

class ChatManager {
    
    typealias ChatCompletion = ((_ success: Bool, _ chats: [Chat], _ message: String?) -> Void)?
    
    var dao: DaoManager!
    var config: Config!
    
    static let sharedInstance: ChatManager = {
        let instance = ChatManager()
        return instance
    }()
    
    init() {
        dao = DaoManager.sharedInstance
        config = Config.sharedInstance
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
                    completion?(false, [], NSLocalizedString("error_object_id", comment: ""))
                default:
                    completion?(false, [], NSLocalizedString("error_unknown", comment: ""))
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
                    completion?(false, [], NSLocalizedString("error_unknown", comment: ""))
                }
            }
        }
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
                for object in result["new"].arrayValue {
                    let room = self.dao.roomDao.saveOrUpdate(object)
                    // Set chat - 1 to sync data.
                    room.chats = room.chats - 1
                }
                for object in result["exist"].arrayValue {
                    let room = self.dao.roomDao.getByRid(object["rid"].stringValue)
                    if room != nil {
                        room?.lastMessage = object["lastMessage"].stringValue
                        room?.updateAt = NSDate(timeIntervalSince1970: object["updateAt"].doubleValue / 1000)
                        room?.unread = object["chats"].int16Value - room!.chats
                    }
                }
                self.dao.saveContext()
                completion?(true)
            } else {
                switch response.errorCode() {
                default:
                    completion?(false)
                }
            }
        }
    }
    
}
