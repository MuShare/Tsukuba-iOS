//
//  MessageManager.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 07/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import Alamofire
import SwiftyJSON

class MessageManager: NSObject {

    var dao: DaoManager!
    
    static let sharedInstance: MessageManager = {
        let instance = MessageManager()
        return instance
    }()
    
    override init() {
        dao = DaoManager.sharedInstance
    }
    
    func create(title: String, introudction: String, sell: Bool, price: Int, oids: [String], cid: String,
                success: ((String) -> Void)?, fail: (() -> Void)?) {
        
        print(JSON(oids).rawString()!)
        
        let params: Parameters = [
            "cid": cid,
            "title": title,
            "introduction": introudction,
            "oids": JSON(oids).rawString()!,
            "price": price,
            "sell": sell
            
        ]
        
        Alamofire.request(createUrl("api/message/create"),
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: tokenHeader())
            .responseJSON { (responseObject) in
                let response = Response(responseObject)
                if response.statusOK() {
                    success?(response.getResult()["mid"].stringValue)
                } else {
                    fail?()
                }
        }
    }
    
}
