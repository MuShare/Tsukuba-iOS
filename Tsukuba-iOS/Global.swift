//
//  Global.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import Alamofire

let DEBUG = true

// Server base url
let baseUrl = "https://tsukuba.mushare.cn/"
//let baseUrl = "http://127.0.0.1:8080/"

func createUrl(_ relative: String) -> String {
    let requestUrl = baseUrl + relative
    return requestUrl
}

func imageURL(_ source: String) -> URL? {
    return URL(string: createUrl(source))
}

open class Color: UIColor {
    open class var main: UIColor {
        get {
            return RGB(0xf46d94)
        }
    }
}

extension DefaultsKeys {
    static let type = DefaultsKey<String?>("type")
    static let identifier = DefaultsKey<String?>("identifier")
    static let name = DefaultsKey<String?>("name")
    static let avatar = DefaultsKey<String?>("avatar")
    static let contact = DefaultsKey<String?>("contact")
    static let address = DefaultsKey<String?>("address")
    static let deviceToken = DefaultsKey<String?>("deviceToken")
    static let token = DefaultsKey<String?>("token")
    static let login = DefaultsKey<Bool?>("login")
    static let categoryRev = DefaultsKey<Int?>("categoryRev")
    static let selectionRev = DefaultsKey<Int?>("selectionRev")
    static let optionRev = DefaultsKey<Int?>("optionRev")
    static let userRev = DefaultsKey<Int?>("userRev")
    static let version = DefaultsKey<String?>("version")
}

enum ErrorCode: Int {
    case badRequest = -99999
    case tokenError = 901
    case emailRegistered = 1011
    case illegalIDeviceOS = 1021
    case emailNotExist = 1022
    case passwordWrong = 1023
    case facebookAccessTokenInvalid = 1031
    case sendResetPasswordMail = 1061
    case modifyMessageMidError = 2022
    case modifyMessageNoPrivilege = 2023
    case savePicture = 2041
}

func token() -> String? {
    return Defaults[.token]
}

func tokenHeader() -> HTTPHeaders? {
    let token = Defaults[.token]
    if token == nil {
        return nil;
    }
    let headers: HTTPHeaders = [
        "token": token!
    ]
    return headers
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: newValue!])
        }
    }
}
