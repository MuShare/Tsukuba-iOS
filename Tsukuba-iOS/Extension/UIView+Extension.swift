//
//  UIView+Extension.swift
//  Tsukuba-iOS
//
//  Created by Meng Li on 2018/06/04.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

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
