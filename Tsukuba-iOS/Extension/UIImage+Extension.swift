//
//  UIImage+Extension.swift
//  Tsukuba-iOS
//
//  Created by Meng Li on 2018/07/04.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

public extension UIImage {
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContext(rect.size)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
    
    public convenience init?(outerColor: UIColor, innerColor: UIColor, size: CGSize = CGSize(width: 1, height: 1), raduisRatio: CGFloat = 1) {
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: [outerColor.cgColor, innerColor.cgColor] as CFArray,
                                        locations: [1.0, 0.0]) else {
            return nil
        }
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let raduis = max(size.width, size.height) * raduisRatio
        UIGraphicsBeginImageContext(size)
        let imageContext = UIGraphicsGetCurrentContext()!
        imageContext.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: raduis, options: .drawsAfterEndLocation)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
    
    func resize(ratio: CGFloat) -> UIImage? {
        let newWidth = size.width * ratio
        let newHeight = size.height * ratio
        return resize(width: newWidth, height: newHeight)
    }
    
    func resize(width: CGFloat) -> UIImage? {
        let ratio = width / size.width
        return resize(ratio: ratio)
    }
    
    func resize(width: CGFloat, height: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
}
