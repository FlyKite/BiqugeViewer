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
}

struct WhiteTheme: Theme {
    let backgroundColor: UIColor = 0xE9E9E9.rgbColor
    let textColor: UIColor = .black
    let statusBarStyle: UIStatusBarStyle = {
        if #available(iOS 13, *) {
            return .darkContent
        }
        return .default
    }()
}

struct YellowTheme: Theme {
    let backgroundColor: UIColor = 0xE6DCC2.rgbColor
    let textColor: UIColor = 0x3C2B13.rgbColor
    let statusBarStyle: UIStatusBarStyle = {
        if #available(iOS 13, *) {
            return .darkContent
        }
        return .default
    }()
}

struct GreenTheme: Theme {
    let backgroundColor: UIColor = 0xC2DABF.rgbColor
    let textColor: UIColor = 0x192018.rgbColor
    let statusBarStyle: UIStatusBarStyle = {
        if #available(iOS 13, *) {
            return .darkContent
        }
        return .default
    }()
}

struct PinkTheme: Theme {
    let backgroundColor: UIColor = 0xE1CECB.rgbColor
    let textColor: UIColor = 0x2D2121.rgbColor
    let statusBarStyle: UIStatusBarStyle = {
        if #available(iOS 13, *) {
            return .darkContent
        }
        return .default
    }()
}

struct DarkTheme: Theme {
    let backgroundColor: UIColor = 0x3C4146.rgbColor
    let textColor: UIColor = 0x8B94A2.rgbColor
    let statusBarStyle: UIStatusBarStyle = .lightContent
}
