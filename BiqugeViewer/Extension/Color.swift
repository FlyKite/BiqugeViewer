//
//  Color.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/21.
//

import UIKit

extension Int {
    var rgbColor: UIColor {
        return rgbColor(alpha: 1)
    }
    
    func rgbColor(alpha: CGFloat) -> UIColor {
        let red = CGFloat((self >> 16) & 0xFF) / 255
        let green = CGFloat((self >> 8) & 0xFF) / 255
        let blue = CGFloat(self & 0xFF) / 255
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIColor {
    convenience init(light: UIColor, dark: UIColor) {
        if #available(iOS 13, *) {
            self.init { (traitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .unspecified:  return light
                case .light:        return light
                case .dark:         return dark
                @unknown default:   return light
                }
            }
        } else {
            self.init(cgColor: light.cgColor)
        }
    }
}
