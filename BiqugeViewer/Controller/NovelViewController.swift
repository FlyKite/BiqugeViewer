//
//  NovelViewController.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/20.
//

import UIKit
import SnapKit

class NovelViewController: UIViewController {
    
    let link: String
    
    init(link: String) {
        self.link = link
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let navigationBar: NovelNavigationBar = NovelNavigationBar()
    private let settingView: NovelSettingView = NovelSettingView()
    private let tableView: UITableView = UITableView()
    private let loadingView: LoadingFooterView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: 0, height: 56))
    
    private var novels: [Novel] = []
    private var novelSizeCache: [String: CGSize] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        NovelManager.lastViewNovelLink = link
        setupViews()
        loadData()
    }
    
    deinit {
        NovelManager.lastViewNovelLink = nil
    }
    
    private func loadData() {
        guard !loadingView.isLoading else { return }
        let link = novels.last?.nextChapterLink ?? self.link
        loadingView.state = .loading
        Network.getNovelPage(path: link) { (result) in
            switch result {
            case let .success(novel):
                if self.navigationBar.title == nil {
                    self.navigationBar.title = novel.title
                }
                self.loadingView.state = .stopped(tips: "加载完成")
                self.novels.append(novel)
            case let .failure(error):
                self.loadingView.state = .stopped(tips: "加载失败，点击重试")
                print(error)
            }
            self.tableView.reloadData()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.currentTheme.statusBarStyle
    }
    
    @objc private func retryLoadData() {
        loadData()
    }
    
    private func handleTap(_ tap: UITapGestureRecognizer) {
        let location = tap.location(in: view)
        let percent = location.y / view.bounds.height
        if percent < 0.33 {
            
        } else if percent > 0.66 {
            
        } else {
            toggleSettingView()
        }
    }
    
    @objc private func toggleSettingView() {
        let show = settingView.isHidden
        settingView.isHidden = false
        navigationBar.isExpanded = show
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
            self.settingView.snp.remakeConstraints { (make) in
                if show {
                    make.left.right.bottom.equalToSuperview()
                } else {
                    make.top.equalTo(self.view.snp.bottom)
                    make.left.right.equalToSuperview()
                }
            }
            self.view.layoutIfNeeded()
        } completion: { (finished) in
            if !show {
                self.settingView.isHidden = true
            }
        }

    }
}

extension NovelViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return novels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NovelCell
        let novel = novels[indexPath.row]
        cell.title = novel.title
        cell.novelContent = NSAttributedString(string: novel.content, attributes: NovelCell.contentAttributes)
        if let size = novelSizeCache[novel.link] {
            cell.horizontalPadding = (view.bounds.width - size.width) / 2
        }
        cell.onTap = { [weak self] (tap) in
            guard let self = self else { return }
            self.handleTap(tap)
        }
        return cell
    }
}

extension NovelViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let novel = novels[indexPath.row]
        if let size = novelSizeCache[novel.link] {
            return size.height
        }
        let size = NovelCell.size(for: novel)
        novelSizeCache[novel.link] = size
        return size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let novel = novels[indexPath.row]
        if let size = novelSizeCache[novel.link] {
            return size.height
        }
        return 56
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        NovelManager.lastViewNovelLink = novels[indexPath.row].link
        if indexPath.row == novels.count - 1 {
            loadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging && navigationBar.isExpanded && settingView.isHidden {
            navigationBar.isExpanded = false
        }
        guard let cell = tableView.visibleCells.first as? NovelCell else { return }
        navigationBar.title = cell.title
    }
}

extension NovelViewController {
    private func setupViews() {
        tableView.register(NovelCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = .zero
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        tableView.tableFooterView = loadingView
        
        loadingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(retryLoadData)))
        
        settingView.isHidden = true
        
        view.addSubview(tableView)
        view.addSubview(navigationBar)
        view.addSubview(settingView)
        
        navigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(settingView.snp.top)
        }
        
        settingView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.tableView.backgroundColor = theme.backgroundColor
        }
    }
}
