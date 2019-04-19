//
//  StreamingParentPlayerViewController.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/03/06.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import RxCocoa
import RxSwift

class StreamingParentPlayerViewController: AVPlayerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "http://18.179.111.10:1935/rinrin/live/playlist.m3u8")
        let playerItem = AVPlayerItem(url: url!)
        let player = AVPlayer(playerItem: playerItem)

        self.player = player

        showsPlaybackControls = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        player?.play()

        StreamingPlayerManager.shared.vcParent = self
    }
}
