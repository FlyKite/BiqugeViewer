//
//  NovelItemCell.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/23.
//

import UIKit

class NovelItemCell: UICollectionViewCell {
    
    func update(title: String, author: String, coverUrl: String) {
        titleLabel.text = title
        authorLabel.text = author
        coverView.kf.setImage(with: URL(string: coverUrl))
    }
    
    private let coverView: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()
    private let authorLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        authorLabel.font = UIFont.systemFont(ofSize: 10)
        authorLabel.textAlignment = .center
        
        contentView.addSubview(coverView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        
        coverView.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
            make.width.equalTo(92)
            make.height.equalTo(112)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(coverView.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
        }
        
        authorLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.left.right.equalToSuperview()
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.backgroundColor = theme.backgroundColor
            self.titleLabel.textColor = theme.textColor
            self.authorLabel.textColor = theme.detailTextColor
        }
    }
}
