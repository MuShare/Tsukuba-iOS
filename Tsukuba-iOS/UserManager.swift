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
                    Defaults[.token] = result?["token"] as? String
                    let user = result?["user"] as! [String: Any]
                    self.type = "email";
                    self.identifier = email
                    self.name = user["name"] as! String
                    self.avatar = user["avatar"] as! String
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

}
