//
//  ChapterListViewController.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/21.
//

import UIKit

class ChapterListViewController: UIViewController {
    
    private let tableView: UITableView = UITableView()
    
    private var page: Int = 0
    private var currentState: LoadingCell.State = .stopped(tips: "")
    private var novelChapters: [NovelChapter] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadData()
    }
    
    private func loadData() {
        if case .loading = currentState {
            return
        }
        let page = self.page + 1
        currentState = .loading
        Network.getNovelChapterList(novelId: "32883", page: page) { (result) in
            switch result {
            case let .success(chapters):
                self.page = page
                self.currentState = .stopped(tips: "加载完毕")
                self.novelChapters.append(contentsOf: chapters)
            case let .failure(error):
                self.currentState = .stopped(tips: "加载失败，点击重试")
                print(error)
            }
            self.tableView.reloadData()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.currentTheme.statusBarStyle
    }
}

extension ChapterListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return novelChapters.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < novelChapters.count else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.state = currentState
            return cell
        }
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
        } else {
            tableView.reloadRows(at: [indexPath], with: .none)
            loadData()
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
        tableView.register(LoadingCell.self, forCellReuseIdentifier: "loadingCell")
        tableView.register(NovelChapterCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 56
        tableView.estimatedRowHeight = 56
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        
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

