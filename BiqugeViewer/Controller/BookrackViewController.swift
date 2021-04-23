//
//  BookrackViewController.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/23.
//

import UIKit

class BookrackViewController: UIViewController {
    
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    private let collectionView: UICollectionView
    
    private let emptyLabel: UILabel = UILabel()
    
    init() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}

extension BookrackViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(NovelItemCell.self, for: indexPath)
        
        return cell
    }
}

extension BookrackViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension BookrackViewController {
    private func setupViews() {
        layout.scrollDirection = .vertical
//        layout.itemSize = CGSize(width: <#T##CGFloat#>, height: <#T##CGFloat#>)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
        
        collectionView.register(NovelItemCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        ThemeManager.shared.register(object: self) { [weak self] (theme) in
            guard let self = self else { return }
            self.collectionView.backgroundColor = theme.backgroundColor
        }
    }
}
