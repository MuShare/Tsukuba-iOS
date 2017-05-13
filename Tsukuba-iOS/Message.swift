//
//  Message.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 10/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import SwiftyJSON

class Message {

    var mid: String!
    var title: String!
    var cover: String!
    var createAt: Date!
    var updateAt: Date!
    var price: Int!
    
    var introduction: String?
    var author: String?
    var avatar: String?
    var paths: [String] = []
    var options: [Option] = []
    
    init(_ object: JSON) {
        mid = object["mid"].stringValue
        title = object["title"].stringValue
        cover = object["cover"].stringValue
        createAt = Date(timeIntervalSince1970: object["createAt"].doubleValue / 1000)
        updateAt = Date(timeIntervalSince1970: object["updateAt"].doubleValue / 1000)
        price = object["price"].intValue
        
        // Detail info
        introduction = object["introduction"].string
        author = object["author"].string
        avatar = object["avatar"].string
        
        // Pictures
        let pictures = object["pictures"].arrayValue;
        if pictures.count > 0 {
            for picture in pictures {
                paths.append(picture["path"].stringValue)
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
