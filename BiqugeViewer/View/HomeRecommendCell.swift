//
//  HomeRecommendCell.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/23.
//

import UIKit

class HomeRecommendCell: UITableViewCell {
    
    var bookClickAction: ((HomeRecommend.BookInfo) -> Void)?
    
    func update(recommend: HomeRecommend) {
        titleLabel.text = recommend.category
        books = recommend.books
        mainBook = recommend.mainBook
        if let book = recommend.mainBook {
            coverView.kf.setImage(with: URL(string: BiqugeApi.coverUrl(id: book.id)))
            bookTitleLabel.text = book.title
            authorLabel.text = book.author
            introduceLabel.text = book.introduce
        }
        bookCollectionView.reloadData()
    }
    
    private var mainBook: HomeRecommend.BookInfo?
    private var books: [HomeRecommend.BookInfo] = []
    
    private let titleLabel: UILabel = UILabel()
    private let mainBookContainer: UIView = UIView()
    private let coverView: UIImageView = UIImageView()
    private let bookTitleLabel: UILabel = UILabel()
    private let authorLabel: UILabel = UILabel()
    private let introduceLabel: UILabel = UILabel()
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    private let bookCollectionView: UICollectionView
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        bookCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        bookCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        selectionStyle = .none
        
        mainBookContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mainBookClicked)))
        
        let titleContainer = UIView()
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        bookTitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        authorLabel.font = UIFont.systemFont(ofSize: 12)
        introduceLabel.font = UIFont.systemFont(ofSize: 14)
        introduceLabel.numberOfLines = 0
        
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 92, height: 170)
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        bookCollectionView.register(BookItemCell.self)
        bookCollectionView.dataSource = self
        bookCollectionView.delegate = self
        bookCollectionView.showsHorizontalScrollIndicator = false
        
        contentView.addSubview(titleContainer)
        titleContainer.addSubview(titleLabel)
        contentView.addSubview(mainBookContainer)
        mainBookContainer.addSubview(coverView)
        mainBookContainer.addSubview(bookTitleLabel)
        mainBookContainer.addSubview(authorLabel)
        mainBookContainer.addSubview(introduceLabel)
        contentView.addSubview(bookCollectionView)
        
        titleContainer.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        
        mainBookContainer.snp.makeConstraints { (make) in
            make.top.equalTo(titleContainer.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        coverView.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(92)
            make.height.equalTo(116)
        }
        
        bookTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(coverView.snp.right).offset(8)
            make.right.lessThanOrEqualToSuperview()
        }
        
        authorLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bookTitleLabel)
            make.top.equalTo(bookTitleLabel.snp.bottom).offset(2)
        }
        
        introduceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bookTitleLabel)
            make.top.equalTo(authorLabel.snp.bottom).offset(8)
            make.right.bottom.lessThanOrEqualToSuperview()
        }
        
        bookCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(mainBookContainer.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(170)
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            titleContainer.backgroundColor = theme.navigationBackgroundColor
            self.backgroundColor = theme.backgroundColor
            self.bookCollectionView.backgroundColor = theme.backgroundColor
            self.titleLabel.textColor = theme.textColor
            self.bookTitleLabel.textColor = theme.textColor
            self.authorLabel.textColor = theme.detailTextColor
            self.introduceLabel.textColor = theme.textColor
        }
    }
    
    @objc private func mainBookClicked() {
        guard let book = mainBook else { return }
        bookClickAction?(book)
    }
}

extension HomeRecommendCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(BookItemCell.self, for: indexPath)
        let book = books[indexPath.item]
        let coverUrl = BiqugeApi.coverUrl(id: book.id)
        cell.update(title: book.title, author: book.author, coverUrl: coverUrl)
        return cell
    }
}

extension HomeRecommendCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        bookClickAction?(books[indexPath.item])
    }
}
