//
//  Global.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import Foundation
import Alamofire

let DEBUG = false

// Server base url
let baseUrl = "https://tsukuba.mushare.cn/"
let socketUrl = "ws://tsukuba.mushare.cn:8080/websocket/chat"

//let baseUrl = "http://192.168.11.2:8080/"
//let socketUrl = "ws://192.168.11.2:8080/websocket/chat"

func createUrl(_ relative: String) -> String {
    let requestUrl = baseUrl + relative
    return requestUrl
}

func imageURL(_ source: String) -> URL? {
    return URL(string: createUrl(source))
}

open class Color: UIColor {
    open class var main: UIColor {
        get {
            return RGB(0x9f62ab)
        }
    }
}

enum ErrorCode: Int {
    case badRequest = -99999
    case objectId = 802
    case tokenError = 901
    case saveFailed = 902
    case invalidParameter = 903
    case emailRegistered = 1011
    case illegalIDeviceOS = 1021
    case emailNotExist = 1022
    case passwordWrong = 1023
    case facebookAccessTokenInvalid = 1031
    case sendResetPasswordMail = 1061
    case modifyMessageNoPrivilege = 2021
    case savePicture = 2041
    case sendPlainText = 3011
}

enum NotificationType: String{
    case didReceivedChat = "didReceiveChat"
    case didSyncRoomStatus = "didSyncRoomStatus"
    case didUnreadChanged = "didUnreadChanged"
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: newValue!])
        }
    }
}

extension UIViewController {
    
    func showTip(_ tip: String) {
        showAlert(title: R.string.localizable.tip_name(),
                  content: tip)
    }
    
    func showAlert(title: String, content: String) {
        let alertController = UIAlertController(title: title,
                                                message: content,
                                                preferredStyle: .alert)
        alertController.view.tintColor = Color.main
        alertController.addAction(UIAlertAction.init(title: R.string.localizable.ok_name(), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func replaceBarButtonItemWithActivityIndicator() {
        let activityIndicatorView = UIActivityIndicatorView.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        activityIndicatorView.startAnimating()
        replaceBaeButtonItemWithView(view: activityIndicatorView)
    }
    
    func replaceBaeButtonItemWithView(view: UIView) {
        let barButton = UIBarButtonItem(customView: view)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func showLoginAlert() {
        let alertController = UIAlertController(title: R.string.localizable.tip_name(),
                                                message: R.string.localizable.sign_in_at_first(),
                                                preferredStyle: .alert)
        alertController.view.tintColor = Color.main
        let signin = UIAlertAction(title: R.string.localizable.sign_in_now(),
                                   style: .destructive,
                                   handler:
        { (action) in
            self.present(UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()!,
                         animated: true, completion: nil)
        })
        let later = UIAlertAction(title: R.string.localizable.later_name(),
                                  style: .cancel,
                                  handler: nil)
        alertController.addAction(signin)
        alertController.addAction(later)
        present(alertController, animated: true, completion: nil)
    }
    
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension UIDevice {
    public func isX() -> Bool {
        if UIScreen.main.bounds.height == 812 {
            return true
        }
        
        return false
    }
}
