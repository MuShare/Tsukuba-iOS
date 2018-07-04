//
//  Data+Extension.swift
//  Tsukuba-iOS
//
//  Created by Meng Li on 2018/07/04.
//  Copyright © 2018 MuShare. All rights reserved.
//

import Foundation

extension Data {
    
    var hexString: String {
        return withUnsafeBytes {(bytes: UnsafePointer<UInt8>) -> String in
            let buffer = UnsafeBufferPointer(start: bytes, count: count)
            return buffer.map {String(format: "%02hhx", $0)}.reduce("", { $0 + $1 })
        }
    }
    
}
