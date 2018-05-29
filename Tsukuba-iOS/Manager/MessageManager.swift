import Alamofire
import SwiftyJSON

class MessageManager {
    
    typealias FavoriteCompletion = ((_ success: Bool, _ favorites: Int, _ message: String?) -> Void)?
    typealias MessagesCompletion = ((Bool, [Message]) -> Void)?
    
    static let pageSize = 18

    var pictureUploadingProgress: Double! = 0
    
    // Updated flag, message need to refresh in user interface or not.
    var updated = false
    
    static let shared = MessageManager()
    
    init() {

    }
    
    func create(title: String, introudction: String, sell: Bool, price: Int, oids: [String], cid: String, completion: ((Bool, String?) -> Void)?) {

        let params: Parameters = [
            "cid": cid,
            "title": title,
            "introduction": introudction,
            "oids": JSON(oids).rawString()!,
            "price": price,
            "sell": sell
        ]
        
        Alamofire.request(createUrl("api/message/create"),
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: Config.shared.tokenHeader)
            .responseJSON { (responseObject) in
                let response = Response(responseObject)
                if response.statusOK() {
                    self.updated = true
                    completion?(true, response.getResult()["mid"].stringValue)
                } else {
                    switch response.errorCode() {
                    case .objectId:
                        completion?(false, R.string.localizable.error_object_id())
                    case .saveFailed:
                        completion?(false, R.string.localizable.error_save_failed())
                    default:
                        completion?(false, R.string.localizable.error_unknown())
                    }
                }
        }
    }
    
    func modify(_ mid: String, title: String, introudction: String, price: Int, oids: [String], completion: ((Bool, String?) -> Void)?) {
        let params: Parameters = [
            "mid": mid,
            "title": title,
            "introduction": introudction,
            "oids": JSON(oids).rawString()!,
            "price": price
        ]
        
        Alamofire.request(createUrl("api/message/modify"),
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: Config.shared.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                self.updated = true
                completion?(true, nil)
            } else {
                switch response.errorCode() {
                case .objectId:
                    completion?(false, R.string.localizable.error_object_id())
                case .saveFailed:
                    completion?(false, R.string.localizable.error_save_failed())
                case .invalidParameter:
                    completion?(false, R.string.localizable.error_invalid_parameter())
                case .modifyMessageNoPrivilege:
                    completion?(false, R.string.localizable.modify_message_no_privilege())
                default:
                    completion?(false, R.string.localizable.error_unknown())
                }
            }
        }
    }
    
    func loadPictures(_ mid: String, completion: ((Bool, [Picture]) -> Void)?) {
        Alamofire.request(createUrl("api/message/pictures/" + mid),
                          method: .get,
                          parameters: nil,
                          encoding: URLEncoding.default,
                          headers: nil)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                var pictures: [Picture] = []
                for object in response.getResult()["pictures"].arrayValue {
                    pictures.append(Picture(object))
                }
                completion?(true, pictures)
            } else {
                completion?(false, [])
            }
        }
    }
    
    func uploadPicture(_ image: UIImage, mid: String, completion: ((Bool, JSON?) -> Void)?) {
        let data = UIImageJPEGRepresentation(resizeImage(image: image, newWidth: 480)!, 1.0)
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data!, withName: "picture", fileName: UUID().uuidString, mimeType: "image/jpeg")
        },
                         usingThreshold: UInt64.init(),
                         to: createUrl("api/message/picture?mid=" + mid),
                         method: .post,
                         headers: Config.shared.tokenHeader,
                         encodingCompletion:
            { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress { progress in
                        self.pictureUploadingProgress = progress.fractionCompleted
                    }
                    upload.responseJSON { responseObject in
                        let response = Response(responseObject)
                        if response.statusOK() {
                            let picture = response.getResult()["picture"]
                            completion?(true, picture)
                        } else {
                            completion?(false, nil)
                        }
                    }
                    break
                case .failure(let encodingError):
                    if DEBUG {
                        debugPrint(encodingError)
                    }
                    completion?(false, nil)
            }
        })
        
    }
    
    func removePicture(_ pid: String, completion: ((Bool) -> Void)?) {
        let params: Parameters = [
            "pid": pid
        ]
        Alamofire.request(createUrl("api/message/picture"),
                          method: .delete,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: Config.shared.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                completion?(response.getResult()["success"].boolValue)
            } else {
                completion?(false)
            }
        }
    }
    
    func loadMyMessage(_ sell: Bool, completion: MessagesCompletion) {
        let params: Parameters = [
            "sell": sell
        ]
        Alamofire.request(createUrl("api/message/list/user"),
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: Config.shared.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                var messages: [Message] = []
                for object in response.getResult()["messages"].arrayValue {
                    messages.append(Message(object))
                }
                completion?(true, messages)
            } else {
                completion?(false, [])
            }
        }
    }
    
    func loadMyFavorites(_ sell: Bool, completion: MessagesCompletion) {
        let params: Parameters = [
            "sell": sell
        ]
        Alamofire.request(createUrl("api/message/list/favorites"),
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: Config.shared.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                var messages: [Message] = []
                for object in response.getResult()["messages"].arrayValue {
                    messages.append(Message(object))
                }
                completion?(true, messages)
            } else {
                completion?(false, [])
            }
        }
    }
    
    func loadMessage(_ sell: Bool, cid: String?, seq: Int?, completion: MessagesCompletion) {
        let params: Parameters = [
            "sell": sell,
            "cid": cid ?? "",
            "seq": seq ?? -1,
        ]
        Alamofire.request(createUrl("api/message/list"),
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: Config.shared.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                var messages: [Message] = []
                for object in response.getResult()["messages"].arrayValue {
                    messages.append(Message(object))
                }
                completion?(true, messages)
            } else {
                completion?(false, [])
            }
        }
    }
    
    func detail(_ mid: String, completion: ((Bool, Message?) -> Void)?) {
        Alamofire.request(createUrl("api/message/detail/" + mid),
                          method: .get,
                          parameters: nil,
                          encoding: URLEncoding.default,
                          headers: Config.shared.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                let object = response.getResult()["message"]
                completion?(true, Message(object))
            } else {
                completion?(false, nil)
            }
        }
    }
    
    func close(_ mid: String, completion: ((Bool, String?) -> Void)?) {
        let params: Parameters = [
            "mid": mid
        ]
        Alamofire.request(createUrl("api/message/close"),
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: Config.shared.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                completion?(true, nil)
            } else {
                switch response.errorCode() {
                case .objectId:
                    completion?(false, R.string.localizable.error_object_id())
                case .modifyMessageNoPrivilege:
                    completion?(false, R.string.localizable.modify_message_no_privilege())
                default:
                    completion?(false, R.string.localizable.error_unknown())
                }
            }
        }
    }
    
    func like(_ mid: String, completion: FavoriteCompletion) {
        let params: Parameters = [
            "mid": mid
        ]
        Alamofire.request(createUrl("api/favorite/like"),
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: Config.shared.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                let favorites = response.getResult()["favorites"].intValue
                completion?(true, favorites ,nil)
            } else {
                completion?(false, 0, R.string.localizable.message_like_fail())
            }
        }
    }
    
    func unlike(_ mid: String, completion: FavoriteCompletion) {
        let params: Parameters = [
            "mid": mid
        ]
        Alamofire.request(createUrl("api/favorite/unlike"),
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: Config.shared.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                let success = response.getResult()["success"].boolValue
                let favorites = response.getResult()["favorites"].intValue
                completion?(success, favorites, nil)
            } else {
                completion?(false, 0, R.string.localizable.message_unlike_fail())
            }
        }
    }
    
}
