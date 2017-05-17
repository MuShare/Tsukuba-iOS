//
//  Message.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 10/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import SwiftyJSON

class Message {

    var mid: String!
    var title: String!
    var cover: String!
    var createAt: Date!
    var updateAt: Date!
    var price: Int!
    var cid: String!
    var enable: Bool
    
    var introduction: String?
    var author: User?
    var pictures: [Picture] = []
    var options: [Option] = []
    
    init(_ object: JSON) {
        mid = object["mid"].stringValue
        title = object["title"].stringValue
        cover = object["cover"].stringValue
        createAt = Date(timeIntervalSince1970: object["createAt"].doubleValue / 1000)
        updateAt = Date(timeIntervalSince1970: object["updateAt"].doubleValue / 1000)
        price = object["price"].intValue
        cid = object["cid"].stringValue
        enable = object["enable"].boolValue
        
        // Detail info
        introduction = object["introduction"].string
        author = User(simpleUser: object["author"])
        
        // Pictures
        let picturesJOSONArray = object["pictures"].arrayValue;
        if picturesJOSONArray.count > 0 {
            for picture in picturesJOSONArray {
                pictures.append(Picture(picture))
            }
        }
        
        // Options
        let oidsJSONArray = object["options"].arrayValue
        if oidsJSONArray.count > 0 {
            var oids: [String] = []
            for oid in oidsJSONArray {
                oids.append(oid.stringValue)
            }
            for option in DaoManager.sharedInstance.optionDao.findInOids(oids) {
                options.append(option)
            }
        }
    }
    
}
