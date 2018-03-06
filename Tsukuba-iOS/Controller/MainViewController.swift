//
//  MainViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 05/03/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    
    let chatManager = ChatManager.sharedInstance
    let config = Config.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveChatNotification), name: NSNotification.Name(rawValue: NotificationType.didReceivedChat.rawValue), object: nil)
        
        checkRoomStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: Notification
    func didReceiveChatNotification(_ notification: Notification) {
        checkRoomStatus()
    }
    
    func checkRoomStatus() {
        chatManager.roomStatus { (success) in
            self.viewControllers?[1].tabBarItem.badgeValue = "\(self.config.globalUnread)"
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationType.didSyncRoomStatus.rawValue),
                                            object: nil,
                                            userInfo: nil)
        }
    }

}
