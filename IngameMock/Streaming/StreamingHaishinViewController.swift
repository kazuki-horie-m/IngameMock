//
//  StreamingHaishinViewController.swift
//  IngameMock
//
//  Created by kazuki.horie.ts on 2019/03/05.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import UIKit
import AVFoundation
import HaishinKit
import VideoToolbox

class StreamingHaishinViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StreamingPlayerManager.shared.vcLive = self
    }
    
    func startLive() {
        let httpStream = HTTPStream()
        httpStream.attachCamera(DeviceUtil.device(withPosition: .back))
        httpStream.attachAudio(AVCaptureDevice.default(for: .audio))
        httpStream.publish("hello")
        
        let hkView = HKView(frame: view.bounds)
        hkView.attachStream(httpStream)
        
        let httpService = HLSService(domain: "", type: "_http._tcp", name: "HaishinKit", port: 8080)
        httpService.startRunning()
        httpService.addHTTPStream(httpStream)
        
        // add ViewController#view
        view.addSubview(hkView)
    }
    
    func stopLive() {
        
    }
}
