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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if DEBUG {
            NSLog("Received remote notification, userInfo = %@", userInfo);
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
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.notification.request.content.notificationType {
        case .chat(let receiverId):
            print("open a chat with " + receiverId)
            break
        case .unknown:
            break
        }
    }
    
}
