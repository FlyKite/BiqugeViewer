//
//  NovelNavigationBar.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/22.
//

import UIKit

class NovelNavigationBar: UIView {
    
    var onBackClick: ((NovelNavigationBar) -> Void)?
    var onLikeClick: ((NovelNavigationBar) -> Void)?
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue}
    }
    
    var isExpanded: Bool = true {
        didSet {
            guard oldValue != isExpanded else { return }
            updateStyle(isExpanded: isExpanded)
        }
    }
    
    var showBackButton: Bool = true {
        didSet {
            backButton.isHidden = !showBackButton
        }
    }
    
    var showLikeButton: Bool = true {
        didSet {
            likeButton.isHidden = !showLikeButton
        }
    }
    
    var isLiked: Bool = false {
        didSet {
            likeButton.setImage(isLiked ? #imageLiteral(resourceName: "like_selected") : #imageLiteral(resourceName: "like_normal"), for: .normal)
            likeButton.tintColor = isLiked ? 0xF44336.rgbColor : ThemeManager.shared.currentTheme.textColor
        }
    }
    
    private let contentView: UIView = UIView()
    private let backButton: UIButton = UIButton(type: .system)
    private let titleLabel: UILabel = UILabel()
    private let likeButton: UIButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backButton.setImage(#imageLiteral(resourceName: "arrow_left"), for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        likeButton.setImage(#imageLiteral(resourceName: "like_normal"), for: .normal)
        likeButton.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
        
        addSubview(contentView)
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(likeButton)
        
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
        
        backButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        likeButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(44)
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.titleLabel.textColor = theme.textColor
            self.backButton.tintColor = theme.textColor
            self.likeButton.tintColor = self.isLiked ? 0xF44336.rgbColor : theme.textColor
            self.backgroundColor = theme.navigationBackgroundColor
        }
    }
    
    @objc private func backButtonClicked() {
        onBackClick?(self)
    }
    
    @objc private func likeButtonClicked() {
        onLikeClick?(self)
    }
    
    private func updateStyle(isExpanded: Bool) {
        backButton.isHidden = !showBackButton
        likeButton.isHidden = !showLikeButton
        superview?.layoutIfNeeded()
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
            self.backButton.alpha = isExpanded ? 1 : 0
            self.likeButton.alpha = isExpanded ? 1 : 0
            self.contentView.snp.updateConstraints { (make) in
                make.top.equalTo(self.safeAreaLayoutGuide).offset(isExpanded ? 0 : -0.3 * self.safeAreaInsets.top)
                make.height.equalTo(isExpanded ? 44 : 18)
            }
            self.superview?.layoutIfNeeded()
        } completion: { (finished) in
            if !isExpanded {
                self.backButton.isHidden = true
                self.likeButton.isHidden = true
            }
        }
        addScaleAnimation(to: titleLabel, isExpanded: isExpanded)
        addScaleAnimation(to: backButton, isExpanded: isExpanded)
        addScaleAnimation(to: likeButton, isExpanded: isExpanded)
    }
    
    private func addScaleAnimation(to view: UIView, isExpanded: Bool) {
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = isExpanded ? 0.6 : 1
        scale.toValue = isExpanded ? 1 : 0.6
        scale.duration = 0.35
        scale.timingFunction = CAMediaTimingFunction(name: .easeOut)
        scale.isRemovedOnCompletion = false
        scale.fillMode = .both
        backButton.layer.add(scale, forKey: "scale")
    }
}
