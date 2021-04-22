//
//  NovelHeaderView.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/22.
//

import UIKit

class NovelSettingView: UIView {
    
    private let contentView: UIView = UIView()
    private var themeViews: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowOpacity = 0.16
        layer.shadowRadius = 16
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = (UIScreen.main.bounds.width - 64 - 36 * 5) / 4
        
        addSubview(contentView)
        contentView.addSubview(stack)
        
        for (index, themeType) in ThemeType.allCases.enumerated() {
            let view = UIView()
            view.tag = index
            view.backgroundColor = themeType.theme.backgroundColor
            view.layer.cornerRadius = 18
            view.layer.borderWidth = 3
            view.layer.borderColor = themeType == ThemeManager.shared.currentThemeType
                ? 0x4CAF50.rgbColor.cgColor
                : UIColor.white.cgColor
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onThemeViewTap)))
            stack.addArrangedSubview(view)
            themeViews.append(view)
            view.snp.makeConstraints { (make) in
                make.width.height.equalTo(36)
            }
        }
        
        contentView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(200)
        }
        stack.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(32)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.backgroundColor = theme.navigationBackgroundColor
        }
    }
    
    @objc private func onThemeViewTap(_ tap: UITapGestureRecognizer) {
        guard let view = tap.view else { return }
        themeViews.forEach { (themeView) in
            themeView.layer.borderColor = themeView == view
                ? 0x4CAF50.rgbColor.cgColor
                : UIColor.white.cgColor
        }
        ThemeManager.shared.changeTheme(to: ThemeType.allCases[view.tag])
    }
}
