//
//  HomeRecommendCell.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/23.
//

import UIKit

class HomeRecommendCell: UITableViewCell {
    
    var novelClickAction: ((HomeRecommend.RecommendNovel) -> Void)?
    
    func update(recommend: HomeRecommend) {
        titleLabel.text = recommend.category
        novelCollection = recommend.novels
        mainNovel = recommend.mainNovel
        if let novel = recommend.mainNovel {
            if novel.id.count > 3 {
                let endIndex = novel.id.index(novel.id.startIndex, offsetBy: novel.id.count - 3)
                let url = "https://www.biquge.com.cn/files/article/image/\(String(novel.id[..<endIndex]))/\(novel.id)/\(novel.id)s.jpg"
                coverView.kf.setImage(with: URL(string: url))
            } else {
                coverView.image = nil
            }
            novelTitleLabel.text = novel.title
            authorLabel.text = novel.author
            introduceLabel.text = novel.introduce
        }
        novelCollectionView.reloadData()
    }
    
    private var mainNovel: HomeRecommend.RecommendNovel?
    private var novelCollection: [HomeRecommend.RecommendNovel] = []
    
    private let titleLabel: UILabel = UILabel()
    private let mainNovelContainer: UIView = UIView()
    private let coverView: UIImageView = UIImageView()
    private let novelTitleLabel: UILabel = UILabel()
    private let authorLabel: UILabel = UILabel()
    private let introduceLabel: UILabel = UILabel()
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    private let novelCollectionView: UICollectionView
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        novelCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        novelCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        selectionStyle = .none
        
        mainNovelContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mainNovelClicked)))
        
        let titleContainer = UIView()
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        novelTitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        authorLabel.font = UIFont.systemFont(ofSize: 12)
        introduceLabel.font = UIFont.systemFont(ofSize: 14)
        introduceLabel.numberOfLines = 0
        
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 92, height: 170)
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        novelCollectionView.register(NovelItemCell.self)
        novelCollectionView.dataSource = self
        novelCollectionView.delegate = self
        novelCollectionView.showsHorizontalScrollIndicator = false
        
        contentView.addSubview(titleContainer)
        titleContainer.addSubview(titleLabel)
        contentView.addSubview(mainNovelContainer)
        mainNovelContainer.addSubview(coverView)
        mainNovelContainer.addSubview(novelTitleLabel)
        mainNovelContainer.addSubview(authorLabel)
        mainNovelContainer.addSubview(introduceLabel)
        contentView.addSubview(novelCollectionView)
        
        titleContainer.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        
        mainNovelContainer.snp.makeConstraints { (make) in
            make.top.equalTo(titleContainer.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        coverView.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(92)
            make.height.equalTo(116)
        }
        
        novelTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(coverView.snp.right).offset(8)
            make.right.lessThanOrEqualToSuperview()
        }
        
        authorLabel.snp.makeConstraints { (make) in
            make.left.equalTo(novelTitleLabel)
            make.top.equalTo(novelTitleLabel.snp.bottom).offset(2)
        }
        
        introduceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(novelTitleLabel)
            make.top.equalTo(authorLabel.snp.bottom).offset(8)
            make.right.bottom.lessThanOrEqualToSuperview()
        }
        
        novelCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(mainNovelContainer.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(170)
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            titleContainer.backgroundColor = theme.navigationBackgroundColor
            self.backgroundColor = theme.backgroundColor
            self.novelCollectionView.backgroundColor = theme.backgroundColor
            self.titleLabel.textColor = theme.textColor
            self.novelTitleLabel.textColor = theme.textColor
            self.authorLabel.textColor = theme.detailTextColor
            self.introduceLabel.textColor = theme.textColor
        }
    }
    
    @objc private func mainNovelClicked() {
        guard let novel = mainNovel else { return }
        novelClickAction?(novel)
    }
}

extension HomeRecommendCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return novelCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(NovelItemCell.self, for: indexPath)
        let novel = novelCollection[indexPath.item]
        var coverUrl: String = ""
        if novel.id.count > 3 {
            let endIndex = novel.id.index(novel.id.startIndex, offsetBy: novel.id.count - 3)
            coverUrl = "https://www.biquge.com.cn/files/article/image/\(String(novel.id[..<endIndex]))/\(novel.id)/\(novel.id)s.jpg"
        }
        cell.update(title: novel.title, author: novel.author, coverUrl: coverUrl)
        return cell
    }
}

extension HomeRecommendCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        novelClickAction?(novelCollection[indexPath.item])
    }
}
