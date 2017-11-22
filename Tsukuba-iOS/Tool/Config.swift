//
//  Config.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 18/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import SwiftyUserDefaults
import Alamofire

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
    static let lan = DefaultsKey<String?>("lan")
    static let columns = DefaultsKey<Int?>("columns")
}

class Config {
    
    var categoryRev: Int {
        set(value) {
            Defaults[.categoryRev] = value
        }
        get {
            return Defaults[.categoryRev] ?? 0
        }
    }
    
    var selectionRev: Int {
        set(value) {
            Defaults[.selectionRev] = value
        }
        get {
            return Defaults[.selectionRev] ?? 0
        }
    }
    
    var optionRev: Int {
        set(value) {
            Defaults[.optionRev] = value
        }
        get {
            return Defaults[.optionRev] ?? 0
        }
    }
    
    var columns: Int {
        set {
            Defaults[.columns] = newValue
        }
        get {
            return Defaults[.columns] ?? 0
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
    
    var tokenHeader: HTTPHeaders {
        get {
            let headers: HTTPHeaders = [
                "token": token
            ]
            return headers
        }
    }
    
    var lan: String {
        set {
            Defaults[.lan] = newValue
        }
        get {
            return Defaults[.lan] ?? ""
        }
    }

    static let sharedInstance: Config = {
        let instance = Config()
        return instance
    }()
    
}
