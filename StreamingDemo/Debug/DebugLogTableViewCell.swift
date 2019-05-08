//
//  DebugLogTableViewCell.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/05/08.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import UIKit

final class DebugLogTableViewCell: UITableViewCell {
    @IBOutlet private weak var bgView: UIView?
    @IBOutlet private weak var label: UILabel?
    
    func setLogData(_ data: AppLogData) {
        label?.text = data.message
        
        let textColor: UIColor
        let bgColor: UIColor
        switch data.level {
        case "error":
            textColor = .white
            bgColor = .red //UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.75)
        case "warning":
            textColor = .darkGray
            bgColor = .yellow //UIColor(red: 1.0, green: 0.95, blue: 0.2, alpha: 0.75)
        default:
            textColor = .white
            bgColor = .darkGray //UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.75)
        }
        
        label?.textColor = textColor
        bgView?.backgroundColor = bgColor
    }
    
    func setClassName(_ name: String) {
        
    }
}
