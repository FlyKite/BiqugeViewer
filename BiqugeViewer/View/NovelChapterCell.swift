//
//  NovelChapterCell.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/21.
//

import UIKit

class NovelChapterCell: UITableViewCell {
    
    var name: String? {
        get { nameLabel.text }
        set { nameLabel.text = newValue }
    }
    
    private let nameLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        accessoryType = .disclosureIndicator
        
        nameLabel.font = UIFont.systemFont(ofSize: 17)
        nameLabel.textColor = .white
        
        contentView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.nameLabel.textColor = theme.textColor
            self.backgroundColor = theme.backgroundColor
        }
    }
}
