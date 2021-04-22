//
//  NovelHeaderView.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/22.
//

import UIKit

class NovelSettingView: UIView {
    
    var isPanelHidden: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
}
