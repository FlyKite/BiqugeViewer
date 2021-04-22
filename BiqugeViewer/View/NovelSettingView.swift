//
//  NovelHeaderView.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/22.
//

import UIKit

class NovelSettingView: UIView {
    
    private let contentView: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        
        addSubview(contentView)
        
        contentView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(200)
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.backgroundColor = theme.navigationBackgroundColor
        }
    }
}
