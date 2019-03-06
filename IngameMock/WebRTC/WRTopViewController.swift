//
//  WRTopViewController.swift
//  IngameMock
//
//  Created by kazuki.horie.ts on 2019/03/06.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import UIKit
import WebRTC
import Starscream

class WRTopViewController: UIViewController {
    @IBOutlet private weak var videoView: RTCEAGLVideoView?
    @IBOutlet private weak var cameraView: RTCCameraPreviewView?
    
    var websocket: WebSocket?
    
    @IBAction func closeButtonAction(_ sender: Any) {
        // Closeボタンを押した時
        websocket?.disconnect()
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        websocket = WebSocket(url: URL(string:
            "wss://conf.space/WebRTCHandsOnSig/tctc13")!)
        websocket?.delegate = self
        websocket?.connect()
    }
    
    
    func LOG(_ body: String = "",
             function: String = #function,
             line: Int = #line)
    {
        print("[\(function) : \(line)] \(body)")
    }
    
}

extension WRTopViewController: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        LOG()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        LOG("error: \(String(describing: error?.localizedDescription))")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        LOG("message: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        LOG("data.count: \(data.count)")
    }
    
}
