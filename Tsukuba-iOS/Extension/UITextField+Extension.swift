//
//  UITextField+Extension.swift
//  Tsukuba-iOS
//
//  Created by Meng Li on 2018/06/04.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

extension UITextField {
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }

}
