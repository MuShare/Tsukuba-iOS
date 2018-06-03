//
//  UIDevice+Extension.swift
//  Tsukuba-iOS
//
//  Created by Meng Li on 2018/06/04.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

extension UIDevice {
    
    public func isX() -> Bool {
        if UIScreen.main.bounds.height == 812 {
            return true
        }
        
        return false
    }
    
}
