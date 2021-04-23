//
//  HomeViewController.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/23.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let tabBar: HomeTabBar = HomeTabBar()
    private let container: UIScrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int((scrollView.contentOffset.x / scrollView.bounds.width).rounded())
        if index != tabBar.selectedIndex {
            tabBar.setSelectedIndex(index)
        }
    }
}

extension HomeViewController {
    private func setupViews() {
        container.showsHorizontalScrollIndicator = false
        container.contentInsetAdjustmentBehavior = .never
        container.isPagingEnabled = true
        container.delegate = self
        
        let bookrack = BookrackViewController()
        addChild(bookrack)
        
        let recommend = RecommendViewController()
        addChild(recommend)
        
        let search = SearchViewController()
        addChild(search)
        
        tabBar.update(titles: ["书架", "推荐", "搜索"], selectedIndex: 0)
        tabBar.onTabClicked = { [weak self] (index) in
            guard let self = self else { return }
            self.container.setContentOffset(CGPoint(x: self.container.bounds.width * CGFloat(index), y: 0), animated: true)
        }
        
        view.addSubview(container)
        view.addSubview(tabBar)
        
        container.addSubview(bookrack.view)
        container.addSubview(recommend.view)
        container.addSubview(search.view)
        
        bookrack.view.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
        recommend.view.snp.makeConstraints { (make) in
            make.left.equalTo(bookrack.view.snp.right)
            make.top.bottom.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
        search.view.snp.makeConstraints { (make) in
            make.left.equalTo(recommend.view.snp.right)
            make.top.bottom.right.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
        container.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(tabBar.snp.top)
        }
        
        tabBar.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.view.backgroundColor = theme.backgroundColor
        }
    }
}
