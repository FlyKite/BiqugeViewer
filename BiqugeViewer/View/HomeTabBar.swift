//
//  HomeTabBar.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/23.
//

import UIKit

class HomeTabBar: UIView {
    
    private(set) var selectedIndex: Int = -1
    
    private(set) var buttonTitles: [String] = []
    
    var onTabClicked: ((Int) -> Void)?
    
    func setSelectedIndex(_ selectedIndex: Int) {
        self.selectedIndex = selectedIndex
        layoutIfNeeded()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.indicator.snp.remakeConstraints { (make) in
                make.centerX.equalTo(self.buttons[selectedIndex])
                make.centerY.equalTo(self.buttonContainer).offset(16)
                make.width.equalTo(24)
                make.height.equalTo(3)
            }
            self.layoutIfNeeded()
        } completion: { (finished) in
            
        }
    }
    
    func update(titles: [String], selectedIndex: Int) {
        self.selectedIndex = selectedIndex
        buttonTitles = titles
        for (index, button) in buttons.enumerated() {
            button.isHidden = index >= titles.count
        }
        let theme = ThemeManager.shared.currentTheme
        for (index, title) in titles.enumerated() {
            let button: UIButton
            if index < buttons.count {
                button = buttons[index]
            } else {
                button = UIButton()
                button.setTitleColor(theme.textColor, for: .normal)
                button.setTitleColor(theme.textColor.withAlphaComponent(0.6), for: .highlighted)
                button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
                buttons.append(button)
                buttonContainer.addArrangedSubview(button)
            }
            button.tag = index
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        }
        indicator.snp.remakeConstraints { (make) in
            make.centerX.equalTo(buttons[selectedIndex])
            make.centerY.equalTo(buttonContainer).offset(18)
            make.width.equalTo(20)
            make.height.equalTo(3)
        }
    }
    
    private let contentView: UIView = UIView()
    private let buttonContainer: UIStackView = UIStackView()
    private var buttons: [UIButton] = []
    private let indicator: UIView = UIView()
    
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
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowRadius = 8
        
        buttonContainer.axis = .horizontal
        buttonContainer.alignment = .fill
        buttonContainer.distribution = .equalSpacing
        buttonContainer.spacing = 40
        
        indicator.layer.cornerRadius = 1.5
        
        addSubview(contentView)
        contentView.addSubview(buttonContainer)
        contentView.addSubview(indicator)
        
        contentView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(49)
        }
        
        buttonContainer.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        indicator.snp.makeConstraints { (make) in
            make.centerX.equalTo(buttonContainer)
            make.centerY.equalTo(buttonContainer).offset(18)
            make.width.equalTo(20)
            make.height.equalTo(3)
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.backgroundColor = theme.navigationBackgroundColor
            for button in self.buttons {
                button.setTitleColor(theme.textColor, for: .normal)
                button.setTitleColor(theme.textColor.withAlphaComponent(0.6), for: .highlighted)
            }
            self.indicator.backgroundColor = theme.textColor
        }
    }
    
    @objc private func buttonClicked(_ button: UIButton) {
        if selectedIndex != button.tag {
            setSelectedIndex(button.tag)
            onTabClicked?(button.tag)
        }
    }
}
