//
//  ViewController.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/20.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private let tableView: UITableView = UITableView()
    
    private var novelChapters: [Novel] = []
    private var novelHeightCache: [String: CGFloat] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        Network.getNovelPage(path: "/book/32883/196858.html") { (result) in
            switch result {
            case let .success(novel):
                self.novelChapters.append(novel)
                self.tableView.reloadData()
                print(novel.content)
            case let .failure(error):
                print(error)
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return novelChapters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NovelCell
        let novel = novelChapters[indexPath.row]
        cell.novelContent = NSAttributedString(string: novel.content, attributes: NovelCell.contentAttributes)
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let novel = novelChapters[indexPath.row]
        if let height = novelHeightCache[novel.link] {
            return height
        }
        let attrContent = NSAttributedString(string: novel.content, attributes: NovelCell.contentAttributes)
        let height = attrContent.boundingRect(with: CGSize(width: view.bounds.width - 20, height: .infinity),
                                              options: [.usesFontLeading, .usesLineFragmentOrigin],
                                              context: nil).size.height
        novelHeightCache[novel.link] = ceil(height) + 32
        return ceil(height) + 32
    }
}

extension ViewController {
    private func setupViews() {
        tableView.register(NovelCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
