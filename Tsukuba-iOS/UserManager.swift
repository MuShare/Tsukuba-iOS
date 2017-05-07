//
//  UserManager.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import Alamofire
import SwiftyUserDefaults

class UserManager: NSObject {
    
    var dao: DaoManager!
    
    var login: Bool {
        set(value) {
            Defaults[.login] = value
        }
        get {
            return Defaults[.login] ?? false
        }
    }

    var type: String {
        set(value) {
            Defaults[.type] = value
        }
        get {
            return Defaults[.type] ?? ""
        }
    }

    var identifier: String {
        set(value) {
            Defaults[.identifier] = value
        }
        get {
            return Defaults[.identifier] ?? ""
        }
    }
    
    var name: String {
        set(value) {
            Defaults[.name] = value
        }
        get {
            return Defaults[.name] ?? ""
        }
    }
    
    var avatar: String {
        set(value) {
            Defaults[.avatar] = value
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
    
    var avatarUploadingProgress: Double!
    
    static let sharedInstance: UserManager = {
        let instance = UserManager()
        return instance
    }()
    
    override init() {
        dao = DaoManager.sharedInstance
    }
    
    func login(email: String, password: String, completionHandler: ((Bool, String?) -> Void)?) {
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
                    completionHandler?(true, nil);
                } else {
                    switch response.errorCode() {
                    case ErrorCode.emailNotExist.rawValue:
                        completionHandler?(false, NSLocalizedString("email_not_exist", comment: ""))
                    case ErrorCode.passwordWrong.rawValue:
                        completionHandler?(false, NSLocalizedString("password_wrong", comment: ""))
                    default:
                        break
                    }
                }
        }
    }
    
    func uploadAvatar(_ image: UIImage, success: (() -> Void)?, fail: (() -> Void)?) {
        let data = UIImageJPEGRepresentation(resizeImage(image: image, newWidth: 480)!, 1.0)
        Alamofire.upload(multipartFormData:{ multipartFormData in
            multipartFormData.append(data!, withName: "avatar", fileName: UUID().uuidString, mimeType: "image/jpeg")
        },
                         usingThreshold: UInt64.init(),
                         to: createUrl("api/user/avatar"),
                         method: .post,
                         headers: tokenHeader(),
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.uploadProgress(closure: { (Progress) in
                                    self.avatarUploadingProgress = Progress.fractionCompleted
                                })
                                upload.responseJSON { responseObject in
                                    let response = Response(responseObject)
                                    if response.statusOK() {
                                        let result = response.getResult()
                                        self.avatar = result["avatar"].stringValue
                                        success?()
                                    } else {
                                        fail?()
                                    }
                                }
                            case .failure(let encodingError):
                                if DEBUG {
                                    debugPrint(encodingError)
                                }
                                fail?()
                            }
        })

    }
    
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

}
