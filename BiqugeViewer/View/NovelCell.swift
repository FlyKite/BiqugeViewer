//
//  NovelCell.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/20.
//

import UIKit

class NovelCell: UITableViewCell {
    
    static let contentAttributes: [NSAttributedString.Key: Any] = {
        let pStyle = NSMutableParagraphStyle()
        pStyle.lineSpacing = 12
        return [.paragraphStyle: pStyle, .font: UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor.white]
    }()
    
    var novelContent: NSAttributedString? {
        get { textView.attributedText }
        set { textView.attributedText = newValue }
    }
    
    private let textView = UITextView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        selectionStyle = .none
        
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 4)
        
        contentView.addSubview(textView)
        
        textView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
