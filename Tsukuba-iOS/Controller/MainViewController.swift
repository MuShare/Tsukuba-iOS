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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRoomStatusUpdated), name: .didRoomStatusUpdated, object: nil)
        
        updateGlobalUnread()
    }

    // MARK: Notification
    @objc func didRoomStatusUpdated(_ notification: Notification) {
        updateGlobalUnread()
    }
    
    // MARK: Service
    private func updateGlobalUnread() {
        if config.globalUnread > 0 {
            self.viewControllers?[1].tabBarItem.badgeValue = "\(config.globalUnread)"
        } else {
            self.viewControllers?[1].tabBarItem.badgeValue = nil
        }
    }

}
