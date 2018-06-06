//
//  Global.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import Foundation
import Alamofire

let DEBUG = false

open class Color: UIColor {
    open class var main: UIColor {
        get {
            return RGB(0x9f62ab)
        }
    }
}

enum ErrorCode: Int {
    case badRequest = -99999
    case objectId = 802
    case tokenError = 901
    case saveFailed = 902
    case invalidParameter = 903
    case emailRegistered = 1011
    case illegalIDeviceOS = 1021
    case emailNotExist = 1022
    case passwordWrong = 1023
    case facebookAccessTokenInvalid = 1031
    case sendResetPasswordMail = 1061
    case modifyMessageNoPrivilege = 2021
    case savePicture = 2041
    case sendPlainText = 3011
}
