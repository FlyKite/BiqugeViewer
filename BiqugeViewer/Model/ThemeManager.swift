//
//  ThemeManager.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/21.
//

import UIKit

enum ThemeType: String, DefaultsCustomType, CaseIterable {
    case white
    case yellow
    case green
    case pink
    case dark
    
    func getStorableValue() -> DefaultsSupportedType {
        return rawValue
    }
    
    init?(storableValue: Any?) {
        guard let value = storableValue as? String else { return nil }
        self.init(rawValue: value)
    }
    
    var theme: Theme {
        switch self {
        case .white: return WhiteTheme()
        case .yellow: return YellowTheme()
        case .green: return GreenTheme()
        case .pink: return PinkTheme()
        case .dark: return DarkTheme()
        }
    }
}

class ThemeManager {
    
    static let shared: ThemeManager = ThemeManager()
    
    private(set) lazy var currentTheme: Theme = currentThemeType.theme
    
    @DefaultsProperty(key: "currentThemeType", defaultValue: .yellow)
    private(set) var currentThemeType: ThemeType
    
    private var observers: [ThemeObserver] = []
    private let queue: DispatchQueue = DispatchQueue(label: "com.flykite.BiqugeViewer.ThemeManager")
    
    private init() { }
    
    func changeTheme(to themeType: ThemeType) {
        let oldThemeType = currentThemeType
        currentThemeType = themeType
        if themeType != oldThemeType {
            currentTheme = currentThemeType.theme
            notifyObservers()
        }
    }
    
    func register(object: AnyObject, onThemeChanged: @escaping (Theme) -> Void) {
        callOnMainQueue {
            onThemeChanged(self.currentTheme)
        }
        queue.async {
            self.observers.append(ThemeObserver(object: object, onThemeChanged: onThemeChanged))
        }
    }
    
    private func notifyObservers() {
        queue.async {
            self.observers.removeAll { $0.object == nil }
            DispatchQueue.main.sync {
                let theme = self.currentTheme
                self.observers.forEach { (observer) in
                    observer.onThemeChanged(theme)
                    if let controller = observer.object as? UIViewController {
                        controller.setNeedsStatusBarAppearanceUpdate()
                    }
                }
            }
        }
    }
    
    private func callOnMainQueue(action: @escaping () -> Void) {
        if Thread.current.isMainThread {
            action()
        } else {
            DispatchQueue.main.async {
                action()
            }
        }
    }
}

private class ThemeObserver {
    private(set) weak var object: AnyObject?
    let onThemeChanged: (Theme) -> Void
    
    init(object: AnyObject, onThemeChanged: @escaping (Theme) -> Void) {
        self.object = object
        self.onThemeChanged = onThemeChanged
    }
}
