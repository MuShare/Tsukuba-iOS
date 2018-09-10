//
//  AppDelegate.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 29/04/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import CoreData
import FacebookCore
import Alamofire
import SwiftyJSON
import AudioToolbox
import UserNotifications

extension Notification.Name {
    static let webSocketConnecting = Notification.Name("org.mushare.tsukuba.webSocketConnecting")
    static let didWebSocketConnected = Notification.Name("org.mushare.tsukuba.didWebSocketConnected")
    static let didRoomStatusUpdated = Notification.Name("org.mushare.tsukuba.didRoomStatusUpdated")
    static let didReceiveNewChat = Notification.Name("org.mushare.tsukuba.didReceiveNewChat")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let config = Config.shared
    
    var isChatting = false
    var waitingRoomId: String? 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        config.autoEnvironment()
        config.setupKingshifer()
        config.setupLanguage(Bundle.main.preferredLocalizations[0].components(separatedBy: "-")[0])
        // Set suitable columns for iPhone and iPad.
        config.setupColumns(UIScreen.main.bounds.size.width)

        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        // Avoid flash of the navigation bar when pushing a new view controller.
        window?.backgroundColor = .white

        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        SocketManager.shared.refreshSocket()
        SocketManager.shared.delegate = self
 
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AppEventsLogger.activate(application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        DaoManager.shared.saveContext()
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return SDKApplicationDelegate.shared.application(application, open: url, options: options)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait;
    }
    
    // MARK: - APNs
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        config.deviceToken = deviceToken.hexString
        if DEBUG {
            NSLog("Device token from APNs server is %@.", config.deviceToken);
        }

        DeviceManager.shared.uploadDeviceToken(config.deviceToken) { (success) in
            if DEBUG {
                print("Device upload success = %@", success)
            }
        }
    }

}

extension AppDelegate: SocketManagerDelegate {
    
    func socketConecting() {
        NotificationCenter.default.post(name: .webSocketConnecting, object: self)
    }
    
    func scoketConnected() {
        NotificationCenter.default.post(name: .didWebSocketConnected, object: self)
    }
    
    func socketDisconnected() {
        
    }
    
    func didReceiveSocketMessage(_ chats: [Chat]) {
        if !isChatting {
            NotificationCenter.default.post(name: .didRoomStatusUpdated, object: self)
        }
        
        // Play a short sound and vibrate after receiving a chat message.
        if let soundUrl = R.file.didReceivedMessageWav() {
            var soundId: SystemSoundID = 0
            
            AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundId)
            
            AudioServicesAddSystemSoundCompletion(soundId, nil, nil, { (soundId, clientData) -> Void in
                AudioServicesDisposeSystemSoundID(soundId)
            }, nil)
            
            AudioServicesPlaySystemSound(soundId)
        }
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        NotificationCenter.default.post(name: .didReceiveNewChat, object: self, userInfo: [
            "chats": chats
        ])
        
        if let roomId = waitingRoomId, let room = DaoManager.shared.roomDao.getByRid(roomId) {
            waitingRoomId = nil
            openChatRoom(room)
        }
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.notification.request.content.notificationType {
        case .chat(let roomId):
            guard let room = DaoManager.shared.roomDao.getByRid(roomId) else {
                // If the room has not be found, save the room id temporarily.
                waitingRoomId = roomId
                return
            }
            openChatRoom(room)
            break
        case .unknown:
            break
        }
    }
    
    func openChatRoom(_ room: Room) {
        if let rootViewController = window?.rootViewController as? UINavigationController {
            rootViewController.popToRootViewController(animated: false)
            if let mainViewController = rootViewController.viewControllers[0] as? MainViewController {
                mainViewController.changeTab(with: .chats)
                if let chatViewController = R.storyboard.chat.chatViewController() {
                    chatViewController.receiver = User(uid: room.receiverId!,
                                                       name: room.receiverName!,
                                                       avatar: room.receiverAvatar!)
                    mainViewController.navigationController?.pushViewController(chatViewController, animated: true)
                }
            }
        }
    }
    
}
