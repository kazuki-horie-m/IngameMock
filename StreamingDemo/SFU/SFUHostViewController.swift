//
//  SFUHostViewController.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/03/12.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import UIKit
import WebRTC
import Starscream
import AVFoundation
import SwiftyJSON

class SFUHostViewController: UIViewController {
    @IBOutlet private weak var videoView: RTCMTLVideoView!
    @IBOutlet private weak var cameraView: RTCMTLVideoView!
    
    @IBOutlet private weak var webRTCStatusLabel: UILabel?
    
    private lazy var signalClient = SignalingClient(serverUrl: Config.janus.signalingServerUrl, protocols: ["janus-protocol"])
    private lazy var webRTCClient = WebRTCClient(iceServers: Config.janus.webRTCIceServers)
    
    private var signalingConnected: Bool = false
    
    private var hasLocalSdp: Bool = false
    private var hasRemoteSdp: Bool = false
    
    private var localCandidateCount: Int = 0
    private var remoteCandidateCount: Int = 0
    
    private var speakerOn: Bool = false
    private var mute: Bool = false
    
    private let transaction1 = "A11111111"
    
    @IBAction func joinButtonAction(_ sender: UIButton) {
        sendJanusCreate()
    }
    
    @IBAction func enableVideoAction(_ sender: UIButton) {
        self.webRTCClient.startCaptureLocalVideo(renderer: cameraView)
        self.webRTCClient.renderRemoteVideo(to: videoView)
    }
    
    @IBAction func getInfoAction(_ sender: UIButton) {
        sendJanusInfo(transaction: transaction1)
    }
    
    @IBAction func disableVideoAction(_ sender: UIButton) {
        webRTCClient.stopCapture()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signalingConnected = false
        self.hasLocalSdp = false
        self.hasRemoteSdp = false
        self.localCandidateCount = 0
        self.remoteCandidateCount = 0
        self.speakerOn = false
        self.webRTCStatusLabel?.text = "New"
        
        self.webRTCClient.delegate = self
        self.signalClient.delegate = self
        
        self.signalClient.connect()
        
        cameraView.contentMode = .scaleAspectFill
        cameraView.clipsToBounds = true
        cameraView.subviews.forEach {
            $0.contentMode = .scaleAspectFill
        }
        
        videoView.clipsToBounds = true
        videoView.contentMode = .scaleAspectFill
        videoView.subviews.forEach {
            $0.contentMode = .scaleAspectFill
        }
    }
    
    private func sendJanusCreate() {
//        "janus": "create",
//        "transaction": "kTV0KzovHFNe"
        
        let packet:[String: Any] = [
                    "janus": "create",
                    "transaction": transaction1
        ]
        
        signalClient.send(packet: packet)
    }
    
    private func sendJanusInfo(transaction: String) {
//        "janus" : "info",
//        "transaction" : "<random alphanumeric string>"
        let packet:[String: Any] = [
            "janus": "info",
            "transaction": transaction
        ]
        
        signalClient.send(packet: packet)
    }
    
    
    private func sendJanusAttach() {
//        "janus": "attach",
//        "plugin": "janus.plugin.videoroom",
//        "opaque_id": "videoroomtest-DpgSaKili8j7",
//        "transaction": "mAK1MfuTtyL8"
        
        let packet:[String: Any] = [
            "janus" : "attach",
            "session_id" : "7430170609432927",
            "plugin" : "videoroomtest",
            "transaction" : "kTV0KzovHFNe"
        ]
        signalClient.send(packet: packet)
    }
    
    private func sendJanusJoin() {
//        "janus": "message",
//        "body": {
//            "request": "join",
//            "room": 1234,
//            "ptype": "publisher",
//            "display": "tctc"
//        },
//            "transaction": "ZDMAQArOHn0s"
    }
    
    private func receiveJanusJoin() {
    }
    
    private func sendJanusOffer() {
//        "janus": "message",
//        "body": {
//            "request": "configure",
//            "audio": true,
//            "video": true
//        },
//        "transaction": "Rrf6qvLNKz2t",
//        "jsep": {
//            "type": "offer",
//            "sdp": "v=0\r\no=mozilla...略"
//        }
    }
    
    private func receiveJanusAnswer() {
//        "janus": "event",
//        "session_id": 7295224440092912,
//        "transaction": "Rrf6qvLNKz2t",
//        "sender": 3445604340575114,
//        "plugindata": {
//            "plugin": "janus.plugin.videoroom",
//            "data": {
//                "videoroom": "event",
//                "room": 1234,
//                "configured": "ok",
//                "audio_codec": "opus",
//                "video_codec": "vp8"
//            }
//        },
//        "jsep": {
//            "type": "answer",
//            "sdp": "v=0\r\no=mozilla...略"
//        }
    }
    
    // 前の。
    private func offer() {
        self.webRTCClient.offer { (sdp) in
            self.hasLocalSdp = true
            self.signalClient.send(sdp: sdp)
        }
    }
    
    // 前の。
    private func receiveAnswer() {
        self.webRTCClient.answer { (localSdp) in
            self.hasLocalSdp = true
            self.signalClient.send(sdp: localSdp)
        }
    }
}

extension SFUHostViewController: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        self.signalingConnected = true
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        self.signalingConnected = false
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        print("Received remote sdp")
        self.webRTCClient.set(remoteSdp: sdp) { (error) in
            self.hasRemoteSdp = true
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        print("Received remote candidate")
        self.remoteCandidateCount += 1
        self.webRTCClient.set(remoteCandidate: candidate)
    }
    
    func didReceiveMessage(_ signalClient: SignalingClient, message: String) {
        let msg = "websocketDidReceiveMessage: " + message
        print(msg)
    }
}

extension SFUHostViewController: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("discovered local candidate")
        self.localCandidateCount += 1
        self.signalClient.send(candidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        let textColor: UIColor
        switch state {
        case .connected, .completed:
            textColor = .green
        case .disconnected:
            textColor = .orange
        case .failed, .closed:
            textColor = .red
        case .new, .checking, .count:
            textColor = .black
        }
        DispatchQueue.main.async {
            self.webRTCStatusLabel?.text = state.description.capitalized
            self.webRTCStatusLabel?.textColor = textColor
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
            let alert = UIAlertController(title: "Message from WebRTC", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
