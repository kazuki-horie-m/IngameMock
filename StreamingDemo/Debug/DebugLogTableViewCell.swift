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
            bgColor = .red
        case "warning":
            textColor = .darkGray
            bgColor = .yellow
        default:
            textColor = .white
            bgColor = .darkGray
        }
        
        label?.textColor = textColor
        bgView?.backgroundColor = bgColor
    }
    
    func setClassName(_ name: String) {
        
    }
}
