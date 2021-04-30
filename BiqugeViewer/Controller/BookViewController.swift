//
//  BookViewController.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/20.
//

import UIKit
import SnapKit

class BookViewController: UIViewController {
    
    let bookId: String
    let link: String
    
    init(bookId: String, link: String) {
        self.bookId = bookId
        self.link = link
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let navigationBar: BookNavigationBar = BookNavigationBar()
    private let settingView: BookSettingView = BookSettingView()
    private let tableView: UITableView = UITableView()
    private let loadingView: LoadingFooterView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: 0, height: 56))
    
    private var chapters: [BookChapter] = []
    private var contentSizeCache: [String: CGSize] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        BookManager.lastViewBookLink = link
        setupViews()
        loadData()
    }
    
    deinit {
        BookManager.lastViewBookLink = nil
    }
    
    private func loadData() {
        guard !loadingView.isLoading else { return }
        guard let link = chapters.isEmpty ? self.link : chapters.last?.nextChapterLink else { return }
        loadingView.state = .loading
        Network.request(BiqugeApi.bookContent(path: link), handler: BiqugeBookChapterHandler()) { result in
            switch result {
            case let .success(chapter):
                if self.navigationBar.title == nil {
                    self.navigationBar.title = chapter.title
                }
                self.loadingView.state = .stopped(tips: "加载完成")
                self.chapters.append(chapter)
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
        let percent = location.y / tableView.bounds.height
        if percent > 0.33 && percent < 0.66 {
            toggleSettingView()
        } else {
            var offset = tableView.contentOffset
            offset.y = max(0, offset.y - (tableView.bounds.height - 120) * (percent < 0.33 ? 1 : -1))
            tableView.setContentOffset(offset, animated: true)
        }
    }
    
    @objc private func toggleSettingView() {
        let show = settingView.isHidden
        settingView.isHidden = false
        navigationBar.isExpanded = show
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
            self.settingView.alpha = show ? 1 : 0
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

extension BookViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chapters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(BookContentCell.self, for: indexPath)
        let chapter = chapters[indexPath.row]
        cell.title = chapter.title
        cell.chapterContent = NSAttributedString(string: chapter.content, attributes: BookContentCell.contentAttributes)
        if let size = contentSizeCache[chapter.link] {
            cell.horizontalPadding = (view.bounds.width - size.width) / 2
        }
        cell.onTap = { [weak self] (tap) in
            guard let self = self else { return }
            self.handleTap(tap)
        }
        return cell
    }
}

extension BookViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let chapter = chapters[indexPath.row]
        if let size = contentSizeCache[chapter.link] {
            return size.height
        }
        let size = BookContentCell.size(for: chapter)
        contentSizeCache[chapter.link] = size
        return size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let chapter = chapters[indexPath.row]
        if let size = contentSizeCache[chapter.link] {
            return size.height
        }
        return UIScreen.main.bounds.height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let chapter = chapters[indexPath.row]
        BookManager.lastViewBookLink = chapter.link
        BookManager.shared.setBookLastRead(bookId: bookId, title: chapter.title, link: chapter.link) { (error) in
            if let error = error {
                print(error)
            }
        }
        if indexPath.row == chapters.count - 1 {
            loadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging && navigationBar.isExpanded {
            if settingView.isHidden {
                navigationBar.isExpanded = false
            } else {
                toggleSettingView()
            }
        }
        guard let cell = tableView.visibleCells.first as? BookContentCell else { return }
        navigationBar.title = cell.title
    }
}

extension BookViewController {
    private func setupViews() {
        tableView.register(BookContentCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = .zero
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        tableView.tableFooterView = loadingView
        
        loadingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(retryLoadData)))
        
        navigationBar.showLikeButton = false
        navigationBar.onBackClick = { [weak self] (bar) in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        
        settingView.isHidden = true
        settingView.alpha = 0
        
        view.addSubview(tableView)
        view.addSubview(navigationBar)
        view.addSubview(settingView)
        
        navigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }
        
        settingView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.tableView.backgroundColor = theme.backgroundColor
        } onFontSizeChanged: { [weak self] (fontSize) in
            guard let self = self else { return }
            self.contentSizeCache = [:]
            self.tableView.reloadData()
        } onLineSpacingChanged: { [weak self] (lineSpacing) in
            guard let self = self else { return }
            self.contentSizeCache = [:]
            self.tableView.reloadData()
        }

    }
}
