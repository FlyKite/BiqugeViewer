//
//  BookrackViewController.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/23.
//

import UIKit

class BookrackViewController: UIViewController {
    
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    private let collectionView: UICollectionView
    
    private let emptyLabel: UILabel = UILabel()
    
    private var books: [BookManager.BookrackBookInfo] = []
    
    init() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func loadData() {
        BookManager.shared.queryLikedBooks { (result) in
            switch result {
            case let .success(books):
                self.books = books
                self.emptyLabel.isHidden = !books.isEmpty
                self.collectionView.reloadData()
            case let .failure(error):
                print(error)
            }
        }
    }
}

extension BookrackViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(BookItemCell.self, for: indexPath)
        let info = books[indexPath.item]
        cell.update(title: info.title, author: info.author, coverUrl: BiqugeApi.coverUrl(id: info.id))
        return cell
    }
}

extension BookrackViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let info = books[indexPath.item]
        let controller = ChapterListViewController(bookId: info.id)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension BookrackViewController {
    private func setupViews() {
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 92, height: 170)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
        
        collectionView.register(BookItemCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        emptyLabel.text = "书\n \n架\n \n空\n \n空\n \n如\n \n也"
        emptyLabel.font = UIFont.systemFont(ofSize: 15)
        emptyLabel.numberOfLines = 0
        
        view.addSubview(collectionView)
        view.addSubview(emptyLabel)
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.collectionView.backgroundColor = theme.backgroundColor
            self.emptyLabel.textColor = theme.detailTextColor
        }
    }
}
