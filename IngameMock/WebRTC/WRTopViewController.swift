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
import AVFoundation

class WRTopViewController: UIViewController {
    @IBOutlet private weak var videoView: RTCEAGLVideoView!
    @IBOutlet private weak var cameraView: RTCCameraPreviewView?
    
    var websocket: WebSocket?
    
    @IBAction func connectButtonAction(_ sender: UIButton) {
        soranohito()
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        // Closeボタンを押した時
        websocket?.disconnect()
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        soranohito()
    }
    
    
    let pcFactory = RTCPeerConnectionFactory()
    var localMediaStream: RTCMediaStream?
    var peer: RTCPeerConnection?
    
    private func soranohito() {
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: ["OfferToReceiveVideo": kRTCMediaConstraintsValueTrue,
                                   "OfferToReceiveAudio": kRTCMediaConstraintsValueTrue],
            optionalConstraints: nil)
        let peerConn = pcFactory.peerConnection(with: RTCConfiguration(),
                                              constraints: constraints,
                                              delegate: nil)
        
        // 映像トラック
        let videoSource = pcFactory.videoSource()
        let videoTrack = pcFactory.videoTrack(with: videoSource,
                                              trackId: "video1")
        
        // 音声トラック
        let audioSource = pcFactory.audioSource(with: nil)
        let audioTrack = pcFactory.audioTrack(with: audioSource,
                                              trackId: "audio1")
        
        // ストリーム
        let stream = pcFactory.mediaStream(withStreamId: "stream1")
        stream.addVideoTrack(videoTrack)
        stream.addAudioTrack(audioTrack)
        
        // ストリームの追加
        peerConn.add(stream)
        
        videoTrack.add(videoView)
    }
    
    private func noServerStart() {
//        peer = [pc_factory peerConnectionWithICEServers:nil constraints:nil delegate:nil];
//        peer = pcFactory.peerConnection(with: <#T##RTCConfiguration#>, constraints: <#T##RTCMediaConstraints#>, delegate: <#T##RTCPeerConnectionDelegate?#>)
        
        // local_video_view = videoView
        
        localMediaStream = pcFactory.mediaStream(withStreamId: "ARDAMS")
        
        var cameraId: String?
        
        for dev in AVCaptureDevice.devices(for: .video) {
            if dev.position == .front {
                cameraId = dev.localizedName
            }
        }
        
//        RTCVideoCapturer *capturer = [RTCVideoCapturer capturerWithDeviceName:camera_id];
        let capturer = RTCVideoCapturer(delegate: self)
//        RTCVideoSource *source     = [pc_factory videoSourceWithCapturer:capturer constraints:nil];
        let source: RTCVideoSource = pcFactory.videoSource()
        
//        RTCVideoTrack *video_track = [pc_factory videoTrackWithID:@"ARDAMSv0" source:source];
        let videoTrack = pcFactory.videoTrack(with: source, trackId: "ARDAMSv0")
        
        localMediaStream?.addVideoTrack(videoTrack)
        videoTrack.add(videoView)
    }
    
    func LOG(_ body: String = "",
             function: String = #function,
             line: Int = #line)
    {
        print("[\(function) : \(line)] \(body)")
    }
    
}

extension WRTopViewController: RTCVideoCapturerDelegate {
    func capturer(_ capturer: RTCVideoCapturer, didCapture frame: RTCVideoFrame) {
    
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
