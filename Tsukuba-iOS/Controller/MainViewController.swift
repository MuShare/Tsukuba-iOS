//
//  MainViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 05/03/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    
    let chatManager = ChatManager.shared
    let config = Config.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveChatNotification), name: NSNotification.Name(rawValue: NotificationType.didReceivedChat.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUnreadChanged), name: NSNotification.Name(rawValue: NotificationType.didUnreadChanged.rawValue), object: nil)
        
        checkRoomStatus()
    }

    // MARK: Notification
    func didReceiveChatNotification(_ notification: Notification) {
        checkRoomStatus()
    }
    
    func didUnreadChanged(_ notification: Notification) {
        self.updateGlobalUnread()
    }
    
    // MARK: Service
    func checkRoomStatus() {
        chatManager.roomStatus { (success) in
            self.updateGlobalUnread()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationType.didSyncRoomStatus.rawValue),
                                            object: nil,
                                            userInfo: nil)
        }
    }
    
    func updateGlobalUnread() {
        if config.globalUnread > 0 {
            self.viewControllers?[1].tabBarItem.badgeValue = "\(config.globalUnread)"
        } else {
            self.viewControllers?[1].tabBarItem.badgeValue = nil
        }
    }

}
