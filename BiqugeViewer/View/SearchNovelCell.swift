//
//  SearchNovelCell.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/24.
//

import UIKit
import Kingfisher

class SearchNovelCell: UITableViewCell {
    
    func updateInfo(title: String, author: String, category: String, introduce: String, coverUrl: String) {
        titleLabel.text = title
        authorLabel.text = author
        categoryLabel.text = category
        introduceLabel.text = introduce
        coverView.kf.setImage(with: URL(string: coverUrl))
    }
    
    private let coverView: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()
    private let authorLabel: UILabel = UILabel()
    private let categoryLabel: UILabel = UILabel()
    private let introduceLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        authorLabel.font = UIFont.systemFont(ofSize: 13)
        categoryLabel.font = UIFont.systemFont(ofSize: 10)
        introduceLabel.font = UIFont.systemFont(ofSize: 14)
        introduceLabel.numberOfLines = 0
        
        contentView.addSubview(coverView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(introduceLabel)
        
        coverView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(16)
            make.width.equalTo(92)
            make.height.equalTo(116)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coverView.snp.right).offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-16)
            make.top.equalTo(coverView)
        }
        
        authorLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
        }
        
        categoryLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(authorLabel.snp.bottom)
        }
        
        introduceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(categoryLabel.snp.bottom).offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-16)
            make.bottom.lessThanOrEqualTo(coverView)
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.backgroundColor = theme.backgroundColor
            self.titleLabel.textColor = theme.textColor
            self.authorLabel.textColor = theme.detailTextColor
            self.categoryLabel.textColor = theme.detailTextColor
            self.introduceLabel.textColor = theme.textColor
        }
    }
}
