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

func createUrl(_ relative: String) -> String {
    let requestUrl = baseUrl + relative
    return requestUrl
}

extension DefaultsKeys {
    static let type = DefaultsKey<String?>("type")
    static let identifier = DefaultsKey<String?>("identifier")
    static let name = DefaultsKey<String?>("name")
    static let deviceToken = DefaultsKey<String?>("deviceToken")
    static let token = DefaultsKey<String?>("token")
    static let login = DefaultsKey<Bool?>("login")
    static let categoryRev = DefaultsKey<Int?>("categoryRev")
    static let selectionRev = DefaultsKey<Int?>("selectionRev")
    static let optionRev = DefaultsKey<Int?>("optionRev")
    static let version = DefaultsKey<String?>("version")
}

enum ErrorCode: Int {
    case badRequest = -99999
    case tokenError = 901
    case emailNotExist = 1022
    case passwordWrong = 1023
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

func categoryRev() -> Int {
    return Defaults[.categoryRev] ?? 0
}

func setCategoryRev(_ rev: Int) {
    Defaults[.categoryRev] = rev
}
