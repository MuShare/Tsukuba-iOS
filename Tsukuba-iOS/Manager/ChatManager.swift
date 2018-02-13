import Alamofire
import SwiftyUserDefaults

class ChatManager {
    
    typealias ChatCompletion = ((_ success: Bool, _ chat: Chat?, _ message: String?) -> Void)?
    
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
        Alamofire.request(createUrl("/api/chat/text"),
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
                    completion?(false, nil, NSLocalizedString("error_object_id", comment: ""))
                default:
                    completion?(false, nil, NSLocalizedString("error_unknown", comment: ""))
                }
            }
        }
    }
    
}
