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
    
    private let infoView: NovelInfoView = NovelInfoView()
    private let tableView: UITableView = UITableView()
    private let loadingView: LoadingFooterView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: 0, height: 56))
    
    private var page: Int = 1
    private var novelInfo: NovelInfo?
    private var novelChapters: [NovelChapter] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        NovelManager.lastViewNovelId = novelId
        setupViews()
        loadData(nextPage: false)
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
                self.infoView.updateInfo(title: info.title,
                                         author: info.author,
                                         state: info.state,
                                         introduce: info.introduce,
                                         coverUrl: info.coverUrl)
                self.novelChapters.append(contentsOf: info.chapters)
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
}

extension ChapterListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return novelChapters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NovelChapterCell
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
            let controller = NovelViewController(link: chapter.link)
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
        infoView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 148)
        
        tableView.register(NovelChapterCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 56
        tableView.estimatedRowHeight = 56
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView.tableFooterView = loadingView
        
        loadingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(retryLoadData)))
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.tableView.backgroundColor = theme.backgroundColor
        }
    }
}

