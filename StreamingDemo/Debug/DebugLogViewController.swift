//
//  DebugLogViewController.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/05/08.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import UIKit

final class DebugLogViewController: UIViewController {
    @IBOutlet private weak var topTableView: UITableView?
    @IBOutlet private weak var bottomTableView: UITableView?
    
    private var topDataSources = [AppLogData]() {
        didSet {
            topTableView?.isHidden = topDataSources.isEmpty
        }
    }
    
    private var bottomDataSources = [String]() {
        didSet {
            bottomTableView?.isHidden = bottomDataSources.isEmpty
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTableView?.rowHeight = UITableView.automaticDimension
        addObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserver()
    }
    
    private func addObserver() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(self.received(_:)), name: Notification.Name.Debug.AppLogNotification, object: nil)
    }
    
    private func removeObserver() {
        let center = NotificationCenter.default
        center.removeObserver(self)
    }
    
    @objc
    private func received(_ notification: Notification) {
        if notification.name == Notification.Name.Debug.AppLogNotification {
            guard let logData = notification.object as? AppLogData else { return }
            
            topDataSources.insert(logData, at: 0)
            topTableView?.reloadSections(IndexSet(arrayLiteral: 0), with: .fade)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.topDataSources = self.topDataSources.dropLast().map { $0 }
                self.topTableView?.reloadData()
            }
        }
    }
}

extension DebugLogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == topTableView {
            return topDataSources.count
        } else if tableView == bottomTableView {
            return bottomDataSources.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == topTableView {
            let data = topDataSources[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DebugLogTableViewCell.className) as? DebugLogTableViewCell
                else { return UITableViewCell(style: .default, reuseIdentifier: nil) }
            cell.setLogData(data)
            return cell
        } else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
    }
    
    
}
