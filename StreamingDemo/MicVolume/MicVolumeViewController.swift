//
//  MicVolumeViewController.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/03/22.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import UIKit

class MicVolumeViewController: UIViewController {
    @IBOutlet private weak var lblAve: UILabel?
    @IBOutlet private weak var lblPeak: UILabel?
    
    let obj = PowerLevel()
    
    @IBAction private func start(sender: UIButton) {
        obj.start() // コンソールにマイク入力のレベルをdB表示
    }
    
    @IBAction private func stop(sender: UIButton) {
        obj.stop() // 処理停止
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        obj.updated = { [unowned self] ave, peak in
            print("\(ave) / \(peak)")
            
            DispatchQueue.main.async {
                self.lblAve?.text = "Average: \(ave)"
                self.lblPeak?.text = "Peak: \(peak)"
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        obj.updated = nil
    }
    
}
