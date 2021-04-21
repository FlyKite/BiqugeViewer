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
    
    private let tableView: UITableView = UITableView()
    
    private var currentState: LoadingCell.State = .stopped(tips: "")
    private var novels: [Novel] = []
    private var novelSizeCache: [String: CGSize] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        loadData()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: true)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: true)
//    }
    
    private func loadData() {
        let link = novels.last?.nextChapterLink ?? self.link
        currentState = .loading
        Network.getNovelPage(path: link) { (result) in
            switch result {
            case let .success(novel):
                self.currentState = .stopped(tips: "加载完成")
                self.novels.append(novel)
            case let .failure(error):
                self.currentState = .stopped(tips: "加载失败，点击重试")
                print(error)
            }
            self.tableView.reloadData()
        }
    }
}

extension NovelViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return novels.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < novels.count else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.state = currentState
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NovelCell
        let novel = novels[indexPath.row]
        cell.title = novel.title
        cell.novelContent = NSAttributedString(string: novel.content, attributes: NovelCell.contentAttributes)
        if let size = novelSizeCache[novel.link] {
            cell.horizontalPadding = (view.bounds.width - size.width) / 2
        }
        return cell
    }
}

extension NovelViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < novels.count else {
            return 56
        }
        let novel = novels[indexPath.row]
        if let size = novelSizeCache[novel.link] {
            return size.height
        }
        let size = NovelCell.size(for: novel)
        novelSizeCache[novel.link] = size
        return size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < novels.count else {
            return 56
        }
        let novel = novels[indexPath.row]
        if let size = novelSizeCache[novel.link] {
            return size.height
        }
        return 56
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == novels.count - 1 {
            loadData()
        }
    }
}

extension NovelViewController {
    private func setupViews() {
        tableView.register(LoadingCell.self, forCellReuseIdentifier: "loadingCell")
        tableView.register(NovelCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
