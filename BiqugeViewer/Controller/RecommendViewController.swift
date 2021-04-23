//
//  RecommendViewController.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/23.
//

import UIKit

class RecommendViewController: UIViewController {
    
    private let tableView: UITableView = UITableView()
    
    private var recommends: [HomeRecommend] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadData()
    }
    
    private func loadData() {
        Network.getHomeRecommend { (result) in
            switch result {
            case let .success(recommends):
                self.recommends = recommends
            case let .failure(error):
                print(error)
            }
            self.tableView.reloadData()
        }
    }
}

extension RecommendViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(HomeRecommendCell.self, for: indexPath)
        cell.update(recommend: recommends[indexPath.row])
        cell.novelClickAction = { [weak self] (novel) in
            guard let self = self else { return }
            let controller = ChapterListViewController(novelId: novel.id)
            self.navigationController?.pushViewController(controller, animated: true)
        }
        return cell
    }
}

extension RecommendViewController: UITableViewDelegate {
    
}

extension RecommendViewController {
    private func setupViews() {
        tableView.register(HomeRecommendCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 370
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
        
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
