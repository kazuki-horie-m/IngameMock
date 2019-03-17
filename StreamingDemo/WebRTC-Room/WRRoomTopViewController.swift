//
//  WRRoomTopViewController.swift
//  StreamingDemo
//
//  Created by Kazuki Horie on 2019/03/16.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import UIKit
import WebRTC

class WRRoomTopViewController: UIViewController {
    @IBOutlet private weak var cameraView: RTCMTLVideoView!
    @IBOutlet private weak var remoteVideo1View: RTCMTLVideoView!
    @IBOutlet private weak var remoteVideo2View: RTCMTLVideoView!
    @IBOutlet private weak var remoteVideo3View: RTCMTLVideoView!
    
    private lazy var signalClient = SignalingRoomClient()
    private lazy var webRTCClient = WebRTCRoomClient(iceServers: Config.room.webRTCIceServers)
    
    
    @IBAction private func button1Action(_ sender: UIButton) {
        signalClient.start()
    }
    
    @IBAction private func button2Action(_ sender: UIButton) {
        
    }
    
    @IBAction private func button3Action(_ sender: UIButton) {
        
    }
    
    @IBAction private func button4Action(_ sender: UIButton) {
        
    }
    

}
