//
//  Theme.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/21.
//

import UIKit

protocol Theme {
    var backgroundColor: UIColor { get }
    var textColor: UIColor { get }
    var statusBarStyle: UIStatusBarStyle { get }
    @available(iOS 12.0, *)
    var userInterfaceStyle: UIUserInterfaceStyle { get }
}

struct WhiteTheme: Theme {
    let backgroundColor: UIColor = 0xEAE9EA.rgbColor
    let textColor: UIColor = .black
    let statusBarStyle: UIStatusBarStyle = {
        if #available(iOS 13, *) {
            return .darkContent
        }
        return .default
    }()
    
    @available(iOS 12.0, *)
    var userInterfaceStyle: UIUserInterfaceStyle { .light }
}

struct YellowTheme: Theme {
    let backgroundColor: UIColor = 0xE8DCBF.rgbColor
    let textColor: UIColor = 0x412A0E.rgbColor
    let statusBarStyle: UIStatusBarStyle = {
        if #available(iOS 13, *) {
            return .darkContent
        }
        return .default
    }()
    
    @available(iOS 12.0, *)
    var userInterfaceStyle: UIUserInterfaceStyle { .light }
}

struct GreenTheme: Theme {
    let backgroundColor: UIColor = 0xBBDBBB.rgbColor
    let textColor: UIColor = 0x172017.rgbColor
    let statusBarStyle: UIStatusBarStyle = {
        if #available(iOS 13, *) {
            return .darkContent
        }
        return .default
    }()
    
    @available(iOS 12.0, *)
    var userInterfaceStyle: UIUserInterfaceStyle { .light }
}

struct PinkTheme: Theme {
    let backgroundColor: UIColor = 0xE4CDCA.rgbColor
    let textColor: UIColor = 0x2F2121.rgbColor
    let statusBarStyle: UIStatusBarStyle = {
        if #available(iOS 13, *) {
            return .darkContent
        }
        return .default
    }()
    
    @available(iOS 12.0, *)
    var userInterfaceStyle: UIUserInterfaceStyle { .light }
}

struct DarkTheme: Theme {
    let backgroundColor: UIColor = 0x3B4147.rgbColor
    let textColor: UIColor = 0x8794A3.rgbColor
    let statusBarStyle: UIStatusBarStyle = .lightContent
    
    @available(iOS 12.0, *)
    var userInterfaceStyle: UIUserInterfaceStyle {
        if #available(iOS 13, *) {
            return .dark
        } else {
            return .light
        }
    }
}
