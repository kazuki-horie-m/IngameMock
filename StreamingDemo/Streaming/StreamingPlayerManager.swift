//
//  StreamingPlayerManager.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/03/05.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import UIKit
import AVKit

class StreamingPlayerManager {
    static let shared = StreamingPlayerManager()

    weak var vcParent: AVPlayerViewController?
    weak var vcChild: AVPlayerViewController?
    weak var vcLive: StreamingHaishinViewController?
}
