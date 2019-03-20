//
//  ReplayKitViewController.swift
//  StreamingDemo
//
//  Created by Kazuki Horie on 2019/03/21.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import UIKit
import ReplayKit

class ReplayKitViewController: UIViewController {
    @IBAction private func startAction(sender: UIButton) {
        start()
    }
    
    @IBAction private func pauseAction(sender: UIButton) {
        
    }
    
    @IBAction private func stopAction(sender: UIButton) {
        
    }
    
    private func start() {
        let controller = RPBroadcastController()
        controller.pauseBroadcast()
    }
}
