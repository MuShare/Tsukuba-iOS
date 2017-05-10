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
    
    init(_ object: JSON) {
        mid = object["mid"].stringValue
        title = object["title"].stringValue
        cover = object["cover"].stringValue
        createAt = Date(timeIntervalSince1970: object["createAt"].doubleValue / 1000)
        updateAt = Date(timeIntervalSince1970: object["updateAt"].doubleValue / 1000)
        price = object["price"].intValue
    }
    
}
