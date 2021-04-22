//
//  NovelCell.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/20.
//

import UIKit

class NovelCell: UITableViewCell {
    
    var onTap: ((UITapGestureRecognizer) -> Void)?
    
    static var contentAttributes: [NSAttributedString.Key: Any] {
        let theme = ThemeManager.shared.currentTheme
        let pStyle = NSMutableParagraphStyle()
        pStyle.lineSpacing = 12
        return [.paragraphStyle: pStyle,
                .font: UIFont.systemFont(ofSize: 18),
                .foregroundColor: theme.textColor]
    }
    
    static func size(for novel: Novel) -> CGSize {
        let title = NSAttributedString(string: novel.title, attributes: [.font: UIFont.systemFont(ofSize: 28, weight: .medium)])
        let titleHeight = title.boundingRect(with: CGSize(width: UIScreen.main.bounds.width - 24, height: .infinity),
                                             options: [.usesFontLeading, .usesLineFragmentOrigin],
                                             context: nil).size.height
        let attrContent = NSAttributedString(string: novel.content, attributes: contentAttributes)
        let size = attrContent.boundingRect(with: CGSize(width: UIScreen.main.bounds.width - 20, height: .infinity),
                                            options: [.usesFontLeading, .usesLineFragmentOrigin],
                                            context: nil).size
        return CGSize(width: ceil(size.width), height: ceil(titleHeight) + ceil(size.height) + 80)
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
    
    private let titleLabel: UILabel = UILabel()
    private let textView: UITextView = UITextView()
    private let textViewTap: UITapGestureRecognizer = UITapGestureRecognizer()
    private let textViewDoubleTap: UITapGestureRecognizer = UITapGestureRecognizer()
    
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
        textView.textContainerInset = UIEdgeInsets(top: 32, left: 0, bottom: 16, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        
        textViewTap.addTarget(self, action: #selector(handleTap))
        textViewTap.delegate = self
        textViewTap.require(toFail: textViewDoubleTap)
        textViewDoubleTap.numberOfTapsRequired = 2
        textViewDoubleTap.delegate = self
        textView.addGestureRecognizer(textViewTap)
        textView.addGestureRecognizer(textViewDoubleTap)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tap)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(textView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(32)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
        
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.titleLabel.textColor = theme.textColor
            self.textView.textColor = theme.textColor
            self.textView.backgroundColor = theme.backgroundColor
            self.backgroundColor = theme.backgroundColor
            if let content = self.novelContent {
                self.textView.attributedText = NSAttributedString(string: content.string, attributes: NovelCell.contentAttributes)
            }
        }
    }
    
    @objc private func handleTap(_ tap: UITapGestureRecognizer) {
        onTap?(tap)
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == textViewTap {
            return textView.selectedRange.length == 0
        } else if gestureRecognizer == textViewDoubleTap {
            return textView.selectedRange.length == 0
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
