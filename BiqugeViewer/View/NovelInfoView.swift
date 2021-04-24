//
//  NovelInfoView.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/23.
//

import UIKit
import Kingfisher

class NovelInfoView: UIView {
    
    var chooseChapterPageAction: (() -> Void)?
    
    func updateInfo(title: String, author: String, state: String, introduce: String, coverUrl: String) {
        titleLabel.text = title
        authorLabel.text = author
        stateLabel.text = state
        introduceLabel.text = introduce
        coverView.kf.setImage(with: URL(string: coverUrl))
    }
    
    private let coverView: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()
    private let authorLabel: UILabel = UILabel()
    private let stateLabel: UILabel = UILabel()
    private let introduceLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        authorLabel.font = UIFont.systemFont(ofSize: 13)
        stateLabel.font = UIFont.systemFont(ofSize: 10)
        introduceLabel.font = UIFont.systemFont(ofSize: 14)
        introduceLabel.numberOfLines = 0
        
        let chapterLabel = UILabel()
        chapterLabel.text = "章节列表"
        chapterLabel.font = UIFont.systemFont(ofSize: 15)
        
        let chooseButton = UIButton()
        chooseButton.setTitle("快速跳转", for: .normal)
        chooseButton.addTarget(self, action: #selector(chooseButtonClicked), for: .touchUpInside)
        chooseButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        chooseButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        addSubview(coverView)
        addSubview(titleLabel)
        addSubview(authorLabel)
        addSubview(stateLabel)
        addSubview(introduceLabel)
        addSubview(chapterLabel)
        addSubview(chooseButton)
        
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
        
        stateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(authorLabel.snp.bottom)
        }
        
        introduceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(stateLabel.snp.bottom).offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-16)
            make.bottom.lessThanOrEqualTo(coverView)
        }
        
        chapterLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coverView)
            make.centerY.equalTo(chooseButton)
        }
        
        chooseButton.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.titleLabel.textColor = theme.textColor
            self.authorLabel.textColor = theme.detailTextColor
            self.stateLabel.textColor = theme.detailTextColor
            self.introduceLabel.textColor = theme.textColor
            chapterLabel.textColor = theme.textColor
            chooseButton.setTitleColor(theme.textColor, for: .normal)
            chooseButton.setTitleColor(theme.textColor.withAlphaComponent(0.6), for: .highlighted)
        }
    }
    
    @objc private func chooseButtonClicked() {
        chooseChapterPageAction?()
    }
}
