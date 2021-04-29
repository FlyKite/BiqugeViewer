//
//  SearchViewController.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/23.
//

import UIKit

class SearchViewController: UIViewController {
    
    private let searchContainer: UIView = UIView()
    private let searchBar: UIView = UIView()
    private let textField: UITextField = UITextField()
    private let searchButton: UIButton = UIButton(type: .system)
    private let tableView: UITableView = UITableView()
    private let loadingView: LoadingFooterView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: 0, height: 56))
    
    private var currentKeyword: String = ""
    private var page: Int = 0
    private var isEnd: Bool = false
    private var searchNovels: [SearchNovelInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @objc private func searchButtonClicked() {
        guard let text = textField.text, !text.isEmpty else { return }
        tableView.isHidden = false
        page = 0
        currentKeyword = text
        searchNovels = []
        tableView.reloadData()
        loadData(page: 1, force: true)
    }
    
    private func loadData(page: Int, force: Bool = false) {
        guard !loadingView.isLoading || force else { return }
        let keyword = currentKeyword
        loadingView.state = .loading
        Network.request(BiqugeApi.searchBooks(keyword: currentKeyword, page: page)) { html in
            return try SearchNovelInfo.handle(from: html)
        } completion: { [weak self] result in
            guard let self = self, keyword == self.currentKeyword else { return }
            switch result {
            case let .success((novels, isEnd)):
                self.isEnd = isEnd
                self.page = page
                if page == 1 {
                    self.searchNovels = novels
                } else {
                    self.searchNovels.append(contentsOf: novels)
                }
                self.loadingView.state = .stopped(tips: "加载完毕")
            case let .failure(error):
                self.loadingView.state = .stopped(tips: "加载失败，点击重试")
                print(error)
            }
            self.tableView.reloadData()
        }
    }
    
    @objc private func retryLoadData() {
        guard !isEnd else { return }
        loadData(page: page + 1)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchNovels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(SearchNovelCell.self, for: indexPath)
        let novel = searchNovels[indexPath.row]
        cell.updateInfo(title: novel.title,
                        author: novel.author,
                        category: novel.category,
                        introduce: novel.introduce,
                        coverUrl: novel.coverUrl)
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let novel = searchNovels[indexPath.row]
        let controller = ChapterListViewController(novelId: novel.id)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == searchNovels.count - 1 && !isEnd {
            loadData(page: page + 1)
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .calculationModeLinear) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.7) {
                self.searchContainer.alpha = 0
                self.searchContainer.snp.remakeConstraints { (make) in
                    make.left.right.equalToSuperview()
                    make.top.equalTo(self.view.safeAreaLayoutGuide)
                    make.height.equalTo(44)
                }
                self.textField.snp.updateConstraints { (make) in
                    make.left.equalTo(self.searchContainer).offset(16)
                }
                self.view.layoutIfNeeded()
            }
            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
                self.searchBar.alpha = 1
            }
        } completion: { (finished) in
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard tableView.isHidden else { return }
        UIView.animateKeyframes(withDuration: 0.35, delay: 0, options: .calculationModeLinear) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                self.searchContainer.alpha = 1
                self.searchContainer.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview().offset(64)
                    make.right.equalToSuperview().offset(-64)
                    make.centerY.equalToSuperview()
                    make.height.equalTo(44)
                }
                self.textField.snp.updateConstraints { (make) in
                    make.left.equalTo(self.searchContainer).offset(12)
                }
                self.view.layoutIfNeeded()
            }
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                self.searchBar.alpha = 0
            }
        } completion: { (finished) in
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButtonClicked()
        textField.resignFirstResponder()
        return true
    }
}

extension SearchViewController {
    private func setupViews() {
        searchBar.layer.shadowColor = UIColor.black.cgColor
        searchBar.layer.shadowOpacity = 0.1
        searchBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchBar.layer.shadowRadius = 8
        searchBar.alpha = 0
        
        searchContainer.layer.borderWidth = 1
        searchContainer.layer.cornerRadius = 6
        
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.returnKeyType = .search
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        
        searchButton.setImage(#imageLiteral(resourceName: "search"), for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonClicked), for: .touchUpInside)
        
        tableView.isHidden = true
        tableView.register(SearchNovelCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 148
        tableView.estimatedRowHeight = 148
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView.tableFooterView = loadingView
        tableView.keyboardDismissMode = .onDrag
        
        loadingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(retryLoadData)))
        
        view.addSubview(tableView)
        view.addSubview(searchBar)
        view.addSubview(searchContainer)
        view.addSubview(textField)
        view.addSubview(searchButton)
        
        searchBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        searchContainer.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(64)
            make.right.equalToSuperview().offset(-64)
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
        }
        
        textField.snp.makeConstraints { (make) in
            make.left.equalTo(searchContainer).offset(12)
            make.top.bottom.equalTo(searchContainer)
            make.right.equalTo(searchButton.snp.left)
        }
        
        searchButton.snp.makeConstraints { (make) in
            make.right.top.bottom.equalTo(searchContainer)
            make.width.equalTo(searchButton.snp.height)
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.searchBar.backgroundColor = theme.navigationBackgroundColor
            self.tableView.backgroundColor = theme.backgroundColor
            self.searchContainer.layer.borderColor = theme.detailTextColor.cgColor
            self.textField.textColor = theme.textColor
            self.textField.attributedPlaceholder = NSAttributedString(string: "书名或作者",
                                                                      attributes: [.font: UIFont.systemFont(ofSize: 15),
                                                                                   .foregroundColor: theme.detailTextColor])
            self.searchButton.tintColor = theme.textColor
        }
    }
}
