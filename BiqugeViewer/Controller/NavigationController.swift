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
        if let bookId = BookManager.lastViewBookId {
            let controller = ChapterListViewController(bookId: bookId)
            viewControllers.append(controller)
            
            if let link = BookManager.lastViewBookLink {
                let controller = BookViewController(bookId: bookId, link: link)
                viewControllers.append(controller)
            }
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
