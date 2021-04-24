//
//  ChapterListViewController.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/21.
//

import UIKit

class ChapterListViewController: UIViewController {
    
    let novelId: String
    
    init(novelId: String) {
        self.novelId = novelId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let navigationBar: NovelNavigationBar = NovelNavigationBar()
    private let infoView: NovelInfoView = NovelInfoView()
    private let tableView: UITableView = UITableView()
    private let loadingView: LoadingFooterView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: 0, height: 56))
    
    private var page: Int = 1
    private var novelInfo: NovelInfo?
    private var novelChapters: [NovelChapter] = []
    
    private var lastReadChapterTitle: String?
    private var lastReadChapterLink: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        NovelManager.lastViewNovelId = novelId
        setupViews()
        loadData(nextPage: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NovelManager.shared.queryNovelLikeAndLastRead(novelId: novelId) { (result) in
            switch result {
            case let .success(info):
                guard let info = info else { return }
                self.navigationBar.isLiked = info.isLiked
                self.lastReadChapterTitle = info.lastReadTitle
                self.lastReadChapterLink = info.lastReadLink
                self.updateLastReadChapter()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func updateLastReadChapter() {
        let hasLastReadChapter = lastReadChapterTitle != nil && lastReadChapterLink != nil
        infoView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: hasLastReadChapter ? 206 : 168)
        infoView.lastReadChapterTitle = lastReadChapterTitle
        if tableView.tableHeaderView == infoView {
            tableView.tableHeaderView = infoView
        }
    }
    
    deinit {
        NovelManager.lastViewNovelId = nil
    }
    
    private func loadData(nextPage: Bool) {
        guard !loadingView.isLoading else { return }
        let page = self.page + (nextPage ? 1 : 0)
        loadingView.state = .loading
        Network.getNovelChapterList(novelId: novelId, page: page) { (result) in
            switch result {
            case let .success(info):
                self.page = page
                self.loadingView.state = .stopped(tips: "加载完毕")
                self.novelInfo = info
                self.navigationBar.title = info.title
                self.infoView.isHidden = false
                self.infoView.updateInfo(title: info.title,
                                         author: info.author,
                                         state: info.state,
                                         introduce: info.introduce,
                                         coverUrl: info.coverUrl)
                if nextPage {
                    self.novelChapters.append(contentsOf: info.chapters)
                } else {
                    self.novelChapters = info.chapters
                }
                NovelManager.shared.insertNovel(novel: info) { (error) in
                    if let error = error {
                        print(error)
                    }
                }
            case let .failure(error):
                self.loadingView.state = .stopped(tips: "加载失败，点击重试")
                print(error)
            }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if tableView.tableHeaderView == nil {
            tableView.tableHeaderView = infoView
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.currentTheme.statusBarStyle
    }
    
    @objc private func retryLoadData() {
        loadData(nextPage: !novelChapters.isEmpty)
    }
    
    private func likeButtonClicked() {
        NovelManager.shared.setNovelLiked(novelId: novelId, isLiked: !navigationBar.isLiked) { (error) in
            if let error = error {
                print(error)
            } else {
                self.navigationBar.isLiked.toggle()
            }
        }
    }
}

extension ChapterListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return novelChapters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(NovelChapterCell.self, for: indexPath)
        let chapter = novelChapters[indexPath.row]
        cell.name = chapter.title
        return cell
    }
}

extension ChapterListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < novelChapters.count {
            let chapter = novelChapters[indexPath.row]
            let controller = NovelViewController(novelId: novelId, link: chapter.link)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == novelChapters.count - 10 {
            loadData(nextPage: true)
        }
    }
}

extension ChapterListViewController {
    private func setupViews() {
        navigationBar.onBackClick = { [weak self] (bar) in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        
        navigationBar.onLikeClick = { [weak self] (bar) in
            guard let self = self else { return }
            self.likeButtonClicked()
        }
        
        infoView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 168)
        infoView.isHidden = true
        infoView.chooseChapterPageAction = { [weak self] in
            guard let self = self, let pageNames = self.novelInfo?.pageNameList else { return }
            let controller = ChapterPageViewController(pageNames: pageNames) { (index) in
                self.page = index + 1
                self.novelChapters = []
                self.tableView.reloadData()
                self.loadData(nextPage: false)
            }
            self.present(controller, animated: true, completion: nil)
        }
        infoView.lastReadChapterClickAction = { [weak self] in
            guard let self = self, let link = self.lastReadChapterLink else { return }
            let controller = NovelViewController(novelId: self.novelId, link: link)
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        tableView.register(NovelChapterCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 56
        tableView.estimatedRowHeight = 56
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView.tableFooterView = loadingView
        
        loadingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(retryLoadData)))
        
        view.addSubview(tableView)
        view.addSubview(navigationBar)
        
        navigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.tableView.backgroundColor = theme.backgroundColor
        }
    }
}

