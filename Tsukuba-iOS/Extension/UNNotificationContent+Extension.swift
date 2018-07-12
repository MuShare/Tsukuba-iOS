//
//  UNNotificationContent+Extension.swift
//  Tsukuba-iOS
//
//  Created by Meng Li on 2018/07/10.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UserNotifications
import SwiftyJSON

enum NotificationType {
    case unknown
    case chat(String)
}

extension UNNotificationContent {
    
    var notificationType: NotificationType {
        let info = JSON(userInfo)
        let category = info["aps"]["category"].stringValue.split(separator: ":")
        if category.count < 2 {
            return .unknown
        }

        switch category[0] {
        case "chat":
            return .chat(String(category[1]))
        default:
            return .unknown
        }
    }
    
}
