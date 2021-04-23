//
//  NavigationController.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/21.
//

import UIKit

class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isHidden = true
        
        var viewControllers: [UIViewController] = [HomeViewController()]
        if let novelId = NovelManager.lastViewNovelId {
            let controller = ChapterListViewController(novelId: novelId)
            viewControllers.append(controller)
        }
        if let link = NovelManager.lastViewNovelLink {
            let controller = NovelViewController(link: link)
            viewControllers.append(controller)
        }
        setViewControllers(viewControllers, animated: false)
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            if #available(iOS 13.0, *) {
                self.overrideUserInterfaceStyle = theme.userInterfaceStyle
            }
        }
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    override var childForHomeIndicatorAutoHidden: UIViewController? {
        return topViewController
    }
}
