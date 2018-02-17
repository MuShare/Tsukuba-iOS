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
                chat.room = self.dao.roomDao.saveOrUpdate(result["chat"]["room"], creator: chat.direction)
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
      
                completion?(true, [], nil)
            } else {
                switch response.errorCode() {
                default:
                    completion?(false, [], NSLocalizedString("error_unknown", comment: ""))
                }
            }
        }
    }
    
}
