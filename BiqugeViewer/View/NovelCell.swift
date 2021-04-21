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
    
    static func size(for novel: Novel) -> CGSize {
        let title = NSAttributedString(string: novel.title, attributes: [.font: UIFont.systemFont(ofSize: 28, weight: .medium)])
        let titleHeight = title.boundingRect(with: CGSize(width: UIScreen.main.bounds.width - 24, height: .infinity),
                                             options: [.usesFontLeading, .usesLineFragmentOrigin],
                                             context: nil).size.height
        let attrContent = NSAttributedString(string: novel.content, attributes: contentAttributes)
        let size = attrContent.boundingRect(with: CGSize(width: UIScreen.main.bounds.width - 20, height: .infinity),
                                            options: [.usesFontLeading, .usesLineFragmentOrigin],
                                            context: nil).size
        return CGSize(width: ceil(size.width), height: ceil(titleHeight) + ceil(size.height) + 48)
    }
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue}
    }
    
    var novelContent: NSAttributedString? {
        get { textView.attributedText }
        set { textView.attributedText = newValue }
    }
    
    var horizontalPadding: CGFloat = 0 {
        didSet {
            textView.textContainerInset = UIEdgeInsets(top: 16, left: horizontalPadding, bottom: 16, right: horizontalPadding)
        }
    }
    
    private let titleLabel = UILabel()
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
        
        titleLabel.text = " "
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        titleLabel.numberOfLines = 0
        
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textAlignment = .justified
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(textView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
        
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
}
