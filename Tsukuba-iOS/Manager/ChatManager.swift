import Alamofire
import SwiftyUserDefaults

class ChatManager {
    
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
    
    func sendPlainText(receiver: String, content: String, completion: ((Bool, String?) -> Void)?) {
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
                let chat = response.getResult()["chat"];
                let room = self.dao.roomDao.saveOrUpdate(chat["room"])
                
                completion?(true, "")
            } else {
                switch response.errorCode() {
                case .sendPlainText:
                    completion?(false, NSLocalizedString("error_object_id", comment: ""))
                default:
                    completion?(false, NSLocalizedString("error_unknown", comment: ""))
                }
            }
        }
    }
    
}
