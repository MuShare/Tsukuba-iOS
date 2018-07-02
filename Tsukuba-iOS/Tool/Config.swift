//
//  Config.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 18/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import SwiftyUserDefaults
import Alamofire
import Kingfisher

extension DefaultsKeys {
    static let uid = DefaultsKey<String?>("uid")
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
    static let globalUnread = DefaultsKey<Int?>("globalUnread")
}

enum ServerEnvironment {
    case local
    case dev
    case production
}

class Config {
    
    static let shared = Config()
    
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
    
    var globalUnread: Int {
        set {
            Defaults[.globalUnread] = newValue
        }
        get {
            return Defaults[.globalUnread] ?? 0
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
    
    var modifier: AnyModifier {
        get {
            return AnyModifier { request in
                var r = request
                r.setValue(self.token, forHTTPHeaderField: "token")
                return r
            }
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
    
    var deviceToken: String {
        set {
            Defaults[.deviceToken] = newValue
        }
        get {
            return Defaults[.deviceToken] ?? ""
        }
    }
    
    var environment: ServerEnvironment? {
        didSet {
            guard let env = environment else {
                return
            }
            switch env {
            case .local:
                host = "192.168.31.3"
                baseUrl = "http://" + host + ":8080/"
                socketUrl = "ws://" + host + ":8080/websocket/chat"
            case .dev:
                host = "dev.tsukuba.mushare.cn"
                baseUrl = "https://" + host + "/"
                socketUrl = "ws://" + host + ":8080/websocket/chat"
            case .production:
                host = "tsukuba.mushare.cn"
                baseUrl = "https://" + host + "/"
                socketUrl = "ws://" + host + ":8080/websocket/chat"
            }
        }
    }
    
    var host: String = "127.0.0.1"
    var baseUrl: String = "http://127.0.0.1:8080/"
    var socketUrl: String = "ws://127.0.0.1:8080/websocket/chat/"
    
    func autoEnvironment() {
        let production : Bool = {
            #if DEBUG
                return false
            #elseif ADHOC
                return false
            #else
                return true
            #endif
        }()
        environment = production ? .production : .dev
    }
    
    func createUrl(_ relative: String) -> String {
        let requestUrl = baseUrl + relative
        return requestUrl
    }
    
    func imageURL(_ source: String) -> URL? {
        return URL(string: createUrl(source))
    }
    
}
