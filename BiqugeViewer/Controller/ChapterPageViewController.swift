//
//  ChapterPageViewController.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/23.
//

import UIKit

class ChapterPageViewController: UIViewController {
    
    let pageNames: [String]
    private let onSelectPage: (Int) -> Void
    
    init(pageNames: [String], onSelectPage: @escaping (Int) -> Void) {
        self.pageNames = pageNames
        self.onSelectPage = onSelectPage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let container: UIView = UIView()
    private let tableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first, touch.location(in: container).y < 0 {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
}

extension ChapterPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pageNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NovelChapterCell
        cell.name = pageNames[indexPath.row]
        return cell
    }
}

extension ChapterPageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelectPage(indexPath.row)
        dismiss(animated: true, completion: nil)
    }
}

extension ChapterPageViewController: CustomPresentableViewController {
    func presentationUpdateViewsForTransition(type: TransitionType, duration: TimeInterval, completeCallback: @escaping () -> Void) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            self.container.snp.remakeConstraints { (make) in
                make.left.right.equalToSuperview()
                switch type {
                case .presenting:
                    make.bottom.equalToSuperview()
                case .dismissing:
                    make.top.equalTo(self.view.snp.bottom)
                }
            }
            self.view.layoutIfNeeded()
        } completion: { (finished) in
            completeCallback()
        }

    }
}

extension ChapterPageViewController {
    private func setupViews() {
        view.backgroundColor = .clear
        
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowRadius = 16
        container.layer.shadowOpacity = 0.36
        container.layer.shadowOffset = CGSize(width: 0, height: -2)
        
        tableView.register(NovelChapterCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 56
        tableView.estimatedRowHeight = 56
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 12
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tableView.layer.masksToBounds = true
        
        view.addSubview(container)
        container.addSubview(tableView)
        
        container.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(container)
            make.height.equalTo(view).multipliedBy(0.75)
        }
        
        let theme = ThemeManager.shared.currentTheme
        tableView.backgroundColor = theme.backgroundColor
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = theme.userInterfaceStyle
        }
    }
}
