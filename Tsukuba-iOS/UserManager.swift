//
//  UserManager.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import Alamofire
import SwiftyUserDefaults

class UserManager {
    
    var dao: DaoManager!
    
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
    
    var avatarUploadingProgress: Double! = 0
    
    static let sharedInstance: UserManager = {
        let instance = UserManager()
        return instance
    }()
    
    init() {
        dao = DaoManager.sharedInstance
    }
    
    func pullUser(completion: ((Bool) -> Void)?) {
        Alamofire.request(createUrl("/api/user"),
                          method: .get,
                          parameters: nil,
                          encoding: URLEncoding.default,
                          headers: tokenHeader())
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                let user = response.getResult()["user"]
                self.name = user["name"].stringValue
                self.avatar = user["avatar"].stringValue
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }
    
    func login(email: String, password: String, completion: ((Bool, String?) -> Void)?) {
        let params: Parameters = [
            "email": email,
            "password": password,
            "identifier": UIDevice.current.identifierForVendor!.uuidString,
            "deviceToken": Defaults[.deviceToken] ?? "",
            "os": UIDevice.current.systemName,
            "version": UIDevice.current.systemVersion,
            "lan": NSLocale.preferredLanguages[0]
        ]
        Alamofire.request(createUrl("api/user/login/email"),
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: nil)
            .responseJSON { (responseObject) in
                let response = Response(responseObject)
                if response.statusOK() {
                    let result = response.getResult()
                    // Login success, save user information to NSUserDefaults.
                    Defaults[.token] = result["token"].stringValue
                    let user = result["user"]
                    self.type = "email";
                    self.identifier = email
                    self.name = user["name"].stringValue
                    self.avatar = user["avatar"].stringValue
                    self.login = true
                    completion?(true, nil);
                } else {
                    switch response.errorCode() {
                    case ErrorCode.emailNotExist.rawValue:
                        completion?(false, NSLocalizedString("email_not_exist", comment: ""))
                    case ErrorCode.passwordWrong.rawValue:
                        completion?(false, NSLocalizedString("password_wrong", comment: ""))
                    default:
                        break
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
                    case ErrorCode.emailRegistered.rawValue:
                        completion?(false, NSLocalizedString("email_registered", comment: ""))
                    default:
                        completion?(false, nil)
                        break
                    }
                }
        }
    }
    
    func logout() {
        self.login = false
        self.token = ""
        self.type = ""
        self.name = ""
        self.avatar = ""
        self.identifier = ""
    }
    
    func uploadAvatar(_ image: UIImage, completion: ((Bool) -> Void)?) {
        let data = UIImageJPEGRepresentation(resizeImage(image: image, newWidth: 480)!, 1.0)
        Alamofire.upload(multipartFormData:{ multipartFormData in
            multipartFormData.append(data!, withName: "avatar", fileName: UUID().uuidString, mimeType: "image/jpeg")
        },
                         usingThreshold: UInt64.init(),
                         to: createUrl("api/user/avatar"),
                         method: .post,
                         headers: tokenHeader(),
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


}
