//
//  LoadingFooterView.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/21.
//

import UIKit

class LoadingFooterView: UIView {
    
    enum State {
        case loading
        case stopped(tips: String)
    }
    
    var state: State = .stopped(tips: "") {
        didSet {
            switch state {
            case .loading:
                loadingView.isHidden = false
                loadingView.startAnimating()
                tipsLabel.text = "正在加载..."
            case let .stopped(tips):
                loadingView.isHidden = true
                loadingView.stopAnimating()
                tipsLabel.text = tips
            }
        }
    }
    
    var isLoading: Bool {
        switch state {
        case .loading: return true
        case .stopped: return false
        }
    }
    
    private let loadingView: UIActivityIndicatorView = {
        if #available(iOS 13, *) {
            return UIActivityIndicatorView(style: .medium)
        }
        return UIActivityIndicatorView(style: .gray)
    }()
    private let tipsLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        
        loadingView.isHidden = true
        
        addSubview(stack)
        stack.addArrangedSubview(loadingView)
        stack.addArrangedSubview(tipsLabel)
        
        stack.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.tipsLabel.textColor = theme.textColor
        }
    }
}
