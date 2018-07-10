//
//  MainViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 05/03/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

enum MainTabType: Int {
    case posts = 0
    case chats = 1
    case me = 2
}

class MainViewController: UITabBarController {
    
    let chatManager = ChatManager.shared
    let config = Config.shared

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        updateNavigationBar(with: .posts)
        UIApplication.shared.statusBarStyle = .lightContent
        NotificationCenter.default.addObserver(self, selector: #selector(didRoomStatusUpdated), name: .didRoomStatusUpdated, object: nil)
        updateGlobalUnread()
    }
    
    @objc func createMessage() {
        guard let viewController = selectedViewController, viewController.isKind(of: MessagesViewController.self) else {
            return
        }
        let messagesViewController = viewController as! MessagesViewController
        messagesViewController.createMessage()
    }

    // MARK: Notification
    @objc func didRoomStatusUpdated(_ notification: Notification) {
        updateGlobalUnread()
    }
    
    // MARK: Service
    private func updateGlobalUnread() {
        guard let viewControllers = self.viewControllers else {
            return
        }
        let viewController = viewControllers[1]
        if config.globalUnread > 0 {
            viewController.tabBarItem.badgeValue = "\(config.globalUnread)"
        } else {
            viewController.tabBarItem.badgeValue = nil
        }
    }
    
    private func updateNavigationBar(with type: MainTabType) {
        switch type {
        case .posts:
            title = R.string.localizable.tab_posts_title()
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.write(), style: .plain, target: self, action: #selector(createMessage))
        case .chats:
            title = R.string.localizable.tab_chats_title()
            navigationItem.rightBarButtonItem = nil
        case .me:
            title = R.string.localizable.tab_me_title()
            navigationItem.rightBarButtonItem = nil
        }
    }

    func changeTab(with type: MainTabType) {
        selectedIndex = type.rawValue
        updateNavigationBar(with: type)
    }
}

extension MainViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.isKind(of: MessagesViewController.self) {
            updateNavigationBar(with: .posts)
        } else if viewController.isKind(of: RoomsViewController.self) {
            updateNavigationBar(with: .chats)
        } else if viewController.isKind(of: MeTableViewController.self) {
            updateNavigationBar(with: .me)
        }
    }
    
}
