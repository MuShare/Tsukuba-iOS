//
//  Picture.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 14/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import SwiftyJSON

class Picture {
    
    var pid: String!
    var path: String!
    
    init(_ object: JSON) {
        pid = object["pid"].stringValue
        path = object["path"].stringValue
    }
    
    init(pid: String, path: String) {
        self.pid = pid
        self.path = path
    }
    
}
