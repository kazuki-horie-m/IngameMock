//
//  StreamingChildPlayerViewController.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/02/27.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import RxCocoa
import RxSwift

class StreamingChildPlayerViewController: AVPlayerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")
        let playerItem = AVPlayerItem(url: url!)
        let player = AVPlayer(playerItem: playerItem)
        
        self.player = player
        
        showsPlaybackControls = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        player?.play()
        
        StreamingPlayerManager.shared.vcChild = self
    }
}
