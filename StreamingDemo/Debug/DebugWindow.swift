//
//  DebugWindow.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/05/08.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import UIKit

final class DebugWindow: UIWindow {
    static let hitTag = 9999
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        
        if hitView.tag == DebugWindow.hitTag { hitView.isHidden = true }
        return nil
    }
}
