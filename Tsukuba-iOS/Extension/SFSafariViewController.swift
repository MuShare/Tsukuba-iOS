//
//  SFSafariViewController.swift
//  Tsukuba-iOS
//
//  Created by Meng Li on 2018/05/31.
//  Copyright © 2018 MuShare. All rights reserved.
//

import SafariServices

extension SFSafariViewController {
    
    private struct AssociatedKeys {
        static var previousStatusBarStyleKey: UInt8 = 0
    }
    
    private var previousStatusBarStyle: UIStatusBarStyle {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.previousStatusBarStyleKey) as! UIStatusBarStyle
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.previousStatusBarStyleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        previousStatusBarStyle = UIApplication.shared.statusBarStyle
        UIApplication.shared.statusBarStyle = .default
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = previousStatusBarStyle
    }
    
}
