import Alamofire
import SwiftyUserDefaults

enum UserType {
    case email
    case facebook
    
    var identifier: String {
        switch self {
        case .email:
            return "email"
        case .facebook:
            return "facebook"
        }
    }
}

protocol UserManagerDelegate: class {
    func didUserLogin(_ type: UserType)
    func didUserLogout()
}

class UserManager {
    
    static let shared = UserManager()
    
    weak var delegate: UserManagerDelegate?

    init() {

    }
    
    var login: Bool {
        set {
            Defaults[.login] = newValue
        }
        get {
            return Defaults[.login] ?? false
        }
    }
    
    var token: String {
        set {
            Defaults[.token] = newValue
        }
        get {
            return Defaults[.token] ?? ""
        }
    }
    
    var uid: String {
        set {
            Defaults[.uid] = newValue
        }
        get {
            return Defaults[.uid] ?? ""
        }
    }

    var type: String {
        set {
            Defaults[.type] = newValue
        }
        get {
            return Defaults[.type] ?? ""
        }
    }

    var identifier: String {
        set {
            Defaults[.identifier] = newValue
        }
        get {
            return Defaults[.identifier] ?? ""
        }
    }
    
    var name: String {
        set {
            Defaults[.name] = newValue
        }
        get {
            return Defaults[.name] ?? ""
        }
    }
    
    var avatar: String {
        set {
            Defaults[.avatar] = newValue
        }
        get {
            return Defaults[.avatar] ?? ""
        }
    }
    
    var avatarURL: URL? {
        get {
            return login ? URL(string: createUrl(avatar)) : nil
        }
    }
    
    var contact: String {
        set {
            Defaults[.contact] = newValue
        }
        get {
            return Defaults[.contact] ?? ""
        }
    }
    
    var address: String  {
        set {
            Defaults[.address] = newValue
        }
        get {
            return Defaults[.address] ?? ""
        }
    }
    
    var userRev: Int {
        set {
            Defaults[.userRev] = newValue
        }
        get {
            return Defaults[.userRev] ?? 0
        }
    }
    
    var avatarUploadingProgress: Double! = 0
    
    func isCurrentUser(_ user: User) -> Bool {
        // If user id is empty, load it from server.
        if self.uid == "" {
            self.userRev = 0
            pullUser(completion:nil)
        }
        return user.uid == self.uid
    }
    
    func pullUser(completion: ((Bool) -> Void)?) {
        let params: Parameters = [
            "rev": self.userRev
        ]
        Alamofire.request(createUrl("/api/user"),
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: Config.shared.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                let result = response.getResult()
                if (result["update"].boolValue) {
                    let user = result["user"]
                    self.name = user["name"].stringValue
                    self.avatar = user["avatar"].stringValue
                    self.contact = user["contact"].stringValue
                    self.address = user["address"].stringValue
                    self.userRev = user["rev"].intValue
                    if self.uid == "" {
                        self.uid = user["uid"].stringValue
                    }
                }
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }
    
    func get(_ uid: String, completion: ((Bool, User?) -> Void)?) {
        Alamofire.request(createUrl("api/user/" + uid),
                          method: .get,
                          parameters: nil,
                          encoding: URLEncoding.default,
                          headers: nil)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                let user = User(user: response.getResult()["user"])
                completion?(true, user)
            } else {
                completion?(false, nil)
            }
        }
    }
    
    func login(email: String, password: String, completion: ((Bool, String?) -> Void)?) {
        let params: Parameters = [
            "email": email,
            "password": password,
            "identifier": UIDevice.current.identifierForVendor!.uuidString,
            "deviceToken": Defaults[.deviceToken] ?? "",
            "os": "iOS",
            "version": UIDevice.current.systemVersion,
            "lan": Config.shared.lan
        ]
        Alamofire.request(createUrl("api/user/login/email"),
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: nil)
        .responseJSON { [weak self] responseObject in
            guard let `self` = self else {
                completion?(false, nil)
                return
            }
            let response = Response(responseObject)
            if response.statusOK() {
                let result = response.getResult()
                // Login success, save user information to NSUserDefaults.
                self.type = UserType.email.identifier
                self.token = result["token"].stringValue
                let user = result["user"]
                self.uid = user["uid"].stringValue
                self.identifier = email
                self.name = user["name"].stringValue
                self.avatar = user["avatar"].stringValue
                self.contact = user["contact"].stringValue
                self.address = user["address"].stringValue
                self.userRev = user["rev"].intValue
                self.login = true
                // Upload device token.
                if Config.shared.deviceToken != "" {
                    DeviceManager.shared.uploadDeviceToken(Config.shared.deviceToken, completion: nil)
                }
                
                ChatManager.shared.roomStatus(isLoginCheck: true)
                self.delegate?.didUserLogin(.email)
                completion?(true, nil)
            } else {
                switch response.errorCode() {
                case .emailNotExist:
                    completion?(false, R.string.localizable.email_not_exist())
                case .passwordWrong:
                    completion?(false, R.string.localizable.password_wrong())
                default:
                    completion?(false, R.string.localizable.error_unknown())
                }
            }
        }
    }
    
    func facebookLogin(_ token: String, completion: ((Bool, String?) -> Void)?) {
        let params: Parameters = [
            "accessToken": token,
            "identifier": UIDevice.current.identifierForVendor!.uuidString,
            "deviceToken": Defaults[.deviceToken] ?? "",
            "os": "iOS",
            "version": UIDevice.current.systemVersion,
            "lan": Config.shared.lan
        ]

        Alamofire.request(createUrl("/api/user/login/facebook"),
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: nil)
        .responseJSON { [weak self] responseObject in
            guard let `self` = self else {
                completion?(false, nil)
                return
            }
            let response = Response(responseObject)
            if response.statusOK() {
                let result = response.getResult()
                // Login success, save user information to NSUserDefaults.
                self.type = UserType.facebook.identifier
                self.token = result["token"].stringValue
                let user = result["user"]
                self.uid = user["uid"].stringValue
                self.identifier = user["identifier"].stringValue
                self.name = user["name"].stringValue
                self.avatar = user["avatar"].stringValue
                self.contact = user["contact"].stringValue
                self.address = user["address"].stringValue
                self.userRev = user["rev"].intValue
                self.login = true
                // Upload device token.
                if Config.shared.deviceToken != "" {
                    DeviceManager.shared.uploadDeviceToken(Config.shared.deviceToken, completion: nil)
                }
                
                ChatManager.shared.roomStatus(isLoginCheck: true)
                self.delegate?.didUserLogin(.facebook)
                completion?(true, nil)
            } else {
                switch response.errorCode() {
                case .facebookAccessTokenInvalid:
                    completion?(false, R.string.localizable.facebook_oauth_error())
                default:
                    completion?(false, R.string.localizable.error_unknown())
                }
            }
        }
    }
    
    func reset(email: String, comletion:((Bool, String?) -> Void)?) {
        let params: Parameters = [
            "email": email,
            "lan": Config.shared.lan
        ]
        
        Alamofire.request(createUrl("api/user/modify/password"),
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: Config.shared.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                comletion?(true, nil)
            } else {
                switch response.errorCode() {
                case .emailNotExist:
                    comletion?(false, R.string.localizable.email_not_exist())
                case .sendResetPasswordMail:
                    comletion?(false, R.string.localizable.reset_password_failed())
                default:
                    comletion?(false, R.string.localizable.error_unknown())
                }
            }
        }

    }
    
    func register(email: String, name: String, password: String, completion: ((Bool, String?) -> Void)?) {
        let parameters: Parameters = [
            "email": email,
            "name": name,
            "password": password
        ]
        
        Alamofire.request(createUrl("api/user/register"),
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil)
        .responseJSON { responseObject in
            let response = Response(responseObject)
            if response.statusOK() {
                completion?(true, nil)
            } else {
                switch response.errorCode() {
                case .emailRegistered:
                    completion?(false, R.string.localizable.email_registered())
                default:
                    completion?(false, R.string.localizable.error_unknown())
                }
            }
        }
    }
    
    func logout() {
        self.login = false
        // Clear all user info.
        self.userRev = 0
        self.uid = ""
        self.token = ""
        self.type = ""
        self.name = ""
        self.avatar = ""
        self.identifier = ""
        self.address = ""
        self.contact = ""
        // Delete all chats and rooms.
        DaoManager.shared.chatDao.deleteAll()
        DaoManager.shared.roomDao.deleteAll()
        
        delegate?.didUserLogout()
    }
    
    func uploadAvatar(_ image: UIImage, completion: ((Bool) -> Void)?) {
        let data = UIImageJPEGRepresentation(resizeImage(image: image, newWidth: 480)!, 1.0)
        Alamofire.upload(multipartFormData:{ multipartFormData in
            multipartFormData.append(data!, withName: "avatar", fileName: UUID().uuidString, mimeType: "image/jpeg")
        },
                         usingThreshold: UInt64.init(),
                         to: createUrl("api/user/avatar"),
                         method: .post,
                         headers: Config.shared.tokenHeader,
                         encodingCompletion:
            { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress { progress in
                        self.avatarUploadingProgress = progress.fractionCompleted
                    }
                    upload.responseJSON { responseObject in
                        let response = Response(responseObject)
                        if response.statusOK() {
                            let result = response.getResult()
                            self.avatar = result["avatar"].stringValue
                            self.avatarUploadingProgress = 0
                            completion?(true)
                        } else {
                            completion?(false)
                        }
                    }
                case .failure(let encodingError):
                    if DEBUG {
                        debugPrint(encodingError)
                    }
                    completion?(false)
            }
        })
    }
    
    func modify(name: String, contact: String, address: String, completion:((Bool) -> Void)?) {
        let params: Parameters = [
            "name": name,
            "contact": contact,
            "address": address
        ]
        
        Alamofire.request(createUrl("api/user/modify/info"),
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: Config.shared.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                let result = response.getResult()
                if result["success"].boolValue {
                    self.userRev = result["rev"].intValue
                    self.name = name
                    self.contact = contact
                    self.address = address
                    completion?(true)
                } else {
                    completion?(false)
                }
            } else {
                completion?(false)
            }
            
        }
    }

}
