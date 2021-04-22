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

enum FontSize: Int, DefaultsCustomType, CaseIterable {
    case verySmall
    case small
    case normal
    case large
    case veryLarge
    
    func getStorableValue() -> DefaultsSupportedType {
        return rawValue
    }
    
    init?(storableValue: Any?) {
        guard let value = storableValue as? Int else { return nil }
        self.init(rawValue: value)
    }
    
    var value: CGFloat {
        switch self {
        case .verySmall: return 14
        case .small: return 16
        case .normal: return 18
        case .large: return 20
        case .veryLarge: return 22
        }
    }
}

enum LineSpacing: Int, DefaultsCustomType, CaseIterable {
    case level1
    case level2
    case level3
    case level4
    case level5
    
    func getStorableValue() -> DefaultsSupportedType {
        return rawValue
    }
    
    init?(storableValue: Any?) {
        guard let value = storableValue as? Int else { return nil }
        self.init(rawValue: value)
    }
    
    var value: CGFloat {
        switch self {
        case .level1: return 8
        case .level2: return 10
        case .level3: return 12
        case .level4: return 14
        case .level5: return 16
        }
    }
}

class ThemeManager {
    
    static let shared: ThemeManager = ThemeManager()
    
    private(set) lazy var currentTheme: Theme = currentThemeType.theme
    
    @DefaultsProperty(key: "currentThemeType", defaultValue: .yellow)
    private(set) var currentThemeType: ThemeType
    
    @DefaultsProperty(key: "fontSize", defaultValue: .normal)
    private(set) var fontSize: FontSize
    
    @DefaultsProperty(key: "lineSpacing", defaultValue: .level3)
    private(set) var lineSpacing: LineSpacing
    
    private var observers: [ThemeObserver] = []
    private let queue: DispatchQueue = DispatchQueue(label: "com.flykite.BiqugeViewer.ThemeManager")
    
    private init() { }
    
    func changeTheme(to themeType: ThemeType) {
        let oldThemeType = currentThemeType
        currentThemeType = themeType
        if themeType != oldThemeType {
            let theme = currentThemeType.theme
            currentTheme = theme
            notifyThemeChanged(theme)
        }
    }
    
    func changeFontSize(to fontSize: FontSize) {
        let oldFontSize = self.fontSize
        self.fontSize = fontSize
        if fontSize != oldFontSize {
            notifyFontSizeChanged(fontSize)
        }
    }
    
    func changeLineSpacing(to lineSpacing: LineSpacing) {
        let oldLineSpacing = self.lineSpacing
        self.lineSpacing = lineSpacing
        if lineSpacing != oldLineSpacing {
            notifyLineSpacingChanged(lineSpacing)
        }
    }
    
    func register(object: AnyObject,
                  onThemeChanged: @escaping (Theme) -> Void,
                  onFontSizeChanged: ((FontSize) -> Void)? = nil,
                  onLineSpacingChanged: ((LineSpacing) -> Void)? = nil) {
        callOnMainQueue {
            onThemeChanged(self.currentTheme)
        }
        queue.async {
            self.observers.append(ThemeObserver(object: object,
                                                onThemeChanged: onThemeChanged,
                                                onFontSizeChanged: onFontSizeChanged,
                                                onLineSpacingChanged: onLineSpacingChanged))
        }
    }
    
    private func notifyThemeChanged(_ theme: Theme) {
        queue.async {
            self.observers.removeAll { $0.object == nil }
            DispatchQueue.main.sync {
                self.observers.forEach { (observer) in
                    observer.onThemeChanged(theme)
                    if let controller = observer.object as? UIViewController {
                        controller.setNeedsStatusBarAppearanceUpdate()
                    }
                }
            }
        }
    }
    
    private func notifyFontSizeChanged(_ fontSize: FontSize) {
        queue.async {
            self.observers.removeAll { $0.object == nil }
            DispatchQueue.main.sync {
                self.observers.forEach { (observer) in
                    observer.onFontSizeChanged?(fontSize)
                }
            }
        }
    }
    
    private func notifyLineSpacingChanged(_ lineSpacing: LineSpacing) {
        queue.async {
            self.observers.removeAll { $0.object == nil }
            DispatchQueue.main.sync {
                self.observers.forEach { (observer) in
                    observer.onLineSpacingChanged?(lineSpacing)
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
    let onFontSizeChanged: ((FontSize) -> Void)?
    let onLineSpacingChanged: ((LineSpacing) -> Void)?
    
    init(object: AnyObject, onThemeChanged: @escaping (Theme) -> Void, onFontSizeChanged: ((FontSize) -> Void)?, onLineSpacingChanged: ((LineSpacing) -> Void)?) {
        self.object = object
        self.onThemeChanged = onThemeChanged
        self.onFontSizeChanged = onFontSizeChanged
        self.onLineSpacingChanged = onLineSpacingChanged
    }
}
