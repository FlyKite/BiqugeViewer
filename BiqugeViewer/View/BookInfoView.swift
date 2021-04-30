//
//  BookInfoView.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/23.
//

import UIKit
import Kingfisher

class BookInfoView: UIView {
    
    var chooseChapterPageAction: (() -> Void)?
    var lastReadChapterClickAction: (() -> Void)?
    
    var lastReadChapterTitle: String? {
        didSet {
            lastReadChapterView.title = lastReadChapterTitle
            lastReadChapterView.isHidden = lastReadChapterTitle?.isEmpty ?? true
        }
    }
    
    func updateInfo(title: String, author: String, category: String, introduce: String, coverUrl: String) {
        titleLabel.text = title
        authorLabel.text = author
        stateLabel.text = category
        introduceLabel.text = introduce
        coverView.kf.setImage(with: URL(string: coverUrl))
    }
    
    private let coverView: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()
    private let authorLabel: UILabel = UILabel()
    private let stateLabel: UILabel = UILabel()
    private let introduceLabel: UILabel = UILabel()
    private let lastReadChapterView: LastReadChapterView = LastReadChapterView()
    
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
        
        let headerView = UIView()
        
        let chapterLabel = UILabel()
        chapterLabel.text = "章节列表"
        chapterLabel.font = UIFont.systemFont(ofSize: 15)
        
        let chooseButton = UIButton()
        chooseButton.setTitle("快速跳转", for: .normal)
        chooseButton.addTarget(self, action: #selector(chooseButtonClicked), for: .touchUpInside)
        chooseButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        chooseButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        
        lastReadChapterView.isHidden = true
        lastReadChapterView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(lastReadChapterViewClicked)))
        
        addSubview(coverView)
        addSubview(titleLabel)
        addSubview(authorLabel)
        addSubview(stateLabel)
        addSubview(introduceLabel)
        addSubview(stack)
        stack.addArrangedSubview(lastReadChapterView)
        stack.addArrangedSubview(headerView)
        headerView.addSubview(chapterLabel)
        headerView.addSubview(chooseButton)
        
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
        
        stack.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
        }
        
        lastReadChapterView.snp.makeConstraints { (make) in
            make.height.equalTo(56)
        }
        
        chapterLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        chooseButton.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
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
    
    @objc private func lastReadChapterViewClicked() {
        lastReadChapterClickAction?()
    }
}

private class LastReadChapterView: UIView {
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    private let titleLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        let label = UILabel()
        label.text = "上次读到"
        label.font = UIFont.systemFont(ofSize: 15)
        
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        
        let arrow = UIButton(type: .system)
        arrow.setImage(#imageLiteral(resourceName: "arrow_right"), for: .normal)
        arrow.isUserInteractionEnabled = false
        arrow.tintColor = 0x9E9E9E.rgbColor
        
        addSubview(label)
        addSubview(titleLabel)
        addSubview(arrow)
        
        label.snp.makeConstraints { (make) in
            make.right.equalTo(titleLabel.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.right.equalTo(arrow.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }
        
        arrow.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.titleLabel.textColor = theme.textColor
            label.textColor = theme.textColor
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        backgroundColor = ThemeManager.shared.currentTheme.navigationBackgroundColor
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        backgroundColor = .clear
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        backgroundColor = .clear
    }
}
