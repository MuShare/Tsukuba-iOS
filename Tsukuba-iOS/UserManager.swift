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
                    Defaults[.type] = "email";
                    Defaults[.identifier] = email
                    Defaults[.token] = result?["token"] as? String
                    Defaults[.name] = result?["name"] as? String
                    Defaults[.login] = true
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
