//
//  ChapterListViewController.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/21.
//

import UIKit

class ChapterListViewController: UIViewController {
    
    private let tableView: UITableView = UITableView()
    private let loadingView: LoadingFooterView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: 0, height: 56))
    
    private var page: Int = 0
    private var novelChapters: [NovelChapter] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadData()
    }
    
    private func loadData() {
        guard !loadingView.isLoading else { return }
        let page = self.page + 1
        loadingView.state = .loading
        Network.getNovelChapterList(novelId: "32883", page: page) { (result) in
            switch result {
            case let .success(chapters):
                self.page = page
                self.loadingView.state = .stopped(tips: "加载完毕")
                self.novelChapters.append(contentsOf: chapters)
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
            loadData()
        }
    }
}

extension ChapterListViewController {
    private func setupViews() {
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

