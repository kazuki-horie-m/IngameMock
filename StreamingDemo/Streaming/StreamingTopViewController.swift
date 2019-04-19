//
//  StreamingTopViewController.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/02/27.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import UIKit
import AVFoundation
import HaishinKit
import VideoToolbox

class StreamingTopViewController: UIViewController {
    @IBOutlet private weak var ipaddressLabel: UILabel?
    @IBOutlet private weak var cameraView: UIView?
    @IBOutlet private weak var parentView: UIView?
    @IBOutlet private weak var childView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction private func switchPlayer(sender: UIButton) {
        let parent = StreamingPlayerManager.shared.vcParent?.player
        let child = StreamingPlayerManager.shared.vcChild?.player

        StreamingPlayerManager.shared.vcParent?.player = child
        StreamingPlayerManager.shared.vcChild?.player = parent
    }

    @IBAction private func switchView(sender: UIButton) {
        let parent = StreamingPlayerManager.shared.vcParent?.player
        let child = StreamingPlayerManager.shared.vcChild?.player

        parent?.play()
        child?.play()
    }

    @IBAction private func startLive(sender: UIButton) {
        StreamingPlayerManager.shared.vcLive?.startLive()
    }

    @IBAction private func stopLive(sender: UIButton) {
        StreamingPlayerManager.shared.vcLive?.stopLive()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        ipaddressLabel?.text = NetworkManager.getIPAddress()
    }
}
