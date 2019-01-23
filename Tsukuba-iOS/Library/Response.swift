//
//  Response.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import Alamofire
import SwiftyJSON

class Response {

    var data: [String: Any]!
    
    init(_ response: DataResponse<Any>) {
        if DEBUG, let res = response.response {
            NSLog("New response, status:\n\(res)")
        }
        data = response.result.value as! Dictionary<String, Any>?
        if DEBUG, let data = data {
            NSLog("Response with JSON:\n\(data)")
        }
    }
    
    func statusOK() -> Bool {
        if data == nil {
            return false
        }
        return data["status"] as! Int == 200
    }
    
    func getResult() -> JSON {
        return JSON(data["result"] as! [String: Any])
    }
    
    func errorCode() -> ErrorCode {
        if data == nil {
            return .badRequest
        }
        guard let code = data["errorCode"] as? Int else {
            return .badRequest
        }
        return ErrorCode(rawValue: code) ?? .badRequest
    }
    
}
