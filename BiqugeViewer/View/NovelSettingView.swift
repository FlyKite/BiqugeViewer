//
//  NovelHeaderView.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/22.
//

import UIKit

class NovelSettingView: UIView {
    
    private let contentView: UIView = UIView()
    private let stackView: UIStackView = UIStackView()
    private let fontSizeSlider: UISlider = UISlider()
    private let lineSpacingSlider: UISlider = UISlider()
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
        
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        
        let themeContainer = setupThemes()
        
        fontSizeSlider.isContinuous = true
        fontSizeSlider.maximumValue = Float(FontSize.allCases.count - 1)
        fontSizeSlider.value = Float(ThemeManager.shared.fontSize.rawValue)
        fontSizeSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        lineSpacingSlider.isContinuous = true
        lineSpacingSlider.maximumValue = Float(LineSpacing.allCases.count - 1)
        lineSpacingSlider.value = Float(ThemeManager.shared.lineSpacing.rawValue)
        lineSpacingSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        addSubview(contentView)
        contentView.addSubview(stackView)
        addField(title: "字体大小", view: fontSizeSlider)
        addField(title: "行间距", view: lineSpacingSlider)
        addField(title: "主题", view: themeContainer)
        
        contentView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(34)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.fontSizeSlider.tintColor = theme.sliderTintColor
            self.lineSpacingSlider.tintColor = theme.sliderTintColor
            self.backgroundColor = theme.navigationBackgroundColor
        }
    }
    
    private func addField(title: String, view: UIView) {
        let stack = UIStackView()
        stack.axis = .horizontal
        
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 15)
        
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(view)
        stackView.addArrangedSubview(stack)
        
        label.snp.makeConstraints { (make) in
            make.width.equalTo(80)
        }
        
        ThemeManager.shared.register(object: self) { (theme) in
            label.textColor = theme.textColor
        }
    }
    
    private func setupThemes() -> UIStackView {
        let themeContainer = UIStackView()
        themeContainer.axis = .horizontal
        themeContainer.spacing = (UIScreen.main.bounds.width - 64 - 80 - 36 * 5) / 4
        
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
            themeContainer.addArrangedSubview(view)
            themeViews.append(view)
            view.snp.makeConstraints { (make) in
                make.width.height.equalTo(36)
            }
        }
        return themeContainer
    }
    
    @objc private func sliderValueChanged(_ slider: UISlider) {
        slider.value = slider.value.rounded()
        if slider == fontSizeSlider {
            let fontSize = FontSize.allCases[Int(slider.value)]
            ThemeManager.shared.changeFontSize(to: fontSize)
        } else if slider == lineSpacingSlider {
            let lineSpacing = LineSpacing.allCases[Int(slider.value)]
            ThemeManager.shared.changeLineSpacing(to: lineSpacing)
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
