//
//  NovelNavigationBar.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/22.
//

import UIKit

class NovelNavigationBar: UIView {
    
    var onBackClick: (() -> Void)?
    
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
    
    private let contentView: UIView = UIView()
    private let backButton: UIButton = UIButton(type: .system)
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
        backButton.setImage(#imageLiteral(resourceName: "arrow_left"), for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        addSubview(contentView)
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        
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
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.titleLabel.textColor = theme.textColor
            self.backButton.tintColor = theme.textColor
            self.backgroundColor = theme.navigationBackgroundColor
        }
    }
    
    @objc private func backButtonClicked() {
        onBackClick?()
    }
    
    private func updateStyle(isExpanded: Bool) {
        backButton.isHidden = false
        superview?.layoutIfNeeded()
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
            self.backButton.alpha = isExpanded ? 1 : 0
            self.contentView.snp.updateConstraints { (make) in
                make.top.equalTo(self.safeAreaLayoutGuide).offset(isExpanded ? 0 : -0.3 * self.safeAreaInsets.top)
                make.height.equalTo(isExpanded ? 44 : 18)
            }
            self.superview?.layoutIfNeeded()
        } completion: { (finished) in
            if !isExpanded {
                self.backButton.isHidden = true
            }
        }
        let titleScale = CABasicAnimation(keyPath: "transform.scale")
        titleScale.fromValue = isExpanded ? 0.6 : 1
        titleScale.toValue = isExpanded ? 1 : 0.6
        titleScale.duration = 0.35
        titleScale.timingFunction = CAMediaTimingFunction(name: .easeOut)
        titleScale.isRemovedOnCompletion = false
        titleScale.fillMode = .both
        titleLabel.layer.add(titleScale, forKey: "scale")
        
        let backScale = CABasicAnimation(keyPath: "transform.scale")
        backScale.fromValue = isExpanded ? 0.6 : 1
        backScale.toValue = isExpanded ? 1 : 0.6
        backScale.duration = 0.35
        backScale.timingFunction = CAMediaTimingFunction(name: .easeOut)
        backScale.isRemovedOnCompletion = false
        backScale.fillMode = .both
        backButton.layer.add(backScale, forKey: "scale")
    }
}
