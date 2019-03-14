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
    
    private lazy var signalClient = SignalingClient(serverUrl: Config.janus.signalingServerUrl, protocols: ["janus-protocol", "janus-admin-protocol"])
    private lazy var webRTCClient = WebRTCClient(iceServers: Config.janus.webRTCIceServers)
    
    private var signalingConnected: Bool = false
    
    private var hasLocalSdp: Bool = false
    private var hasRemoteSdp: Bool = false
    
    private var localCandidateCount: Int = 0
    private var remoteCandidateCount: Int = 0
    
    private var speakerOn: Bool = false
    private var mute: Bool = false
    
    enum SignalType: String {
        case create = "create"
        case attach = "attach"
        case handle = "handle"
        case keepalive = "keepaplive"
        case info = "info"
        

        
        var transaction: String {
            let device: String = "iPhone"
            let userId: String = "TCTC"
            return device + "-" + userId + "-" + self.rawValue
        }
    }
    

    
    
    
    @IBAction func joinButtonAction(_ sender: UIButton) {
        sendJanusCreate()
    }
    
    @IBAction func enableVideoAction(_ sender: UIButton) {
        self.webRTCClient.startCaptureLocalVideo(renderer: cameraView)
        self.webRTCClient.renderRemoteVideo(to: videoView)
    }
    
    @IBAction func getInfoAction(_ sender: UIButton) {
        sendJanusInfo()
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
        let packet:[String: Any] = [
                    "janus": "create",
                    "transaction": SignalType.create.transaction
        ]
        
        signalClient.send(packet: packet)
    }
    
    private func sendJanusInfo() {
        let packet:[String: Any] = [
            "janus": "info",
            "transaction": SignalType.info.transaction
        ]
        
        signalClient.send(packet: packet)
    }
    
    
    private func sendJanusAttach(_ sessionId: Int64) {
        let packet:[String: Any] = [
            "janus" : "attach",
            "session_id" : sessionId,
            "plugin" : "janus.plugin.videoroom",
            "transaction" : SignalType.attach.transaction
        ]
        signalClient.send(packet: packet)
    }
    
    private func sendJanusHandle(sessionId: Int64, handleId: Int64) {
        let packet:[String: Any] = [
            "janus" : "message",
            "session_id" : sessionId,
            "handle_id" : handleId,
            "transaction" : SignalType.handle.transaction,
            "body" : [
                "video": true,
                "audio":true
            ]
        ]
        
        signalClient.send(packet: packet)
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
    
    fileprivate func parse(_ jsonData: JSON) {
        guard let transaction = jsonData["transaction"].string
            else {
                print("unknown message")
                return
        }
        
        switch transaction {
        case SignalType.create.transaction:
            receivedCreated(jsonData)
        case SignalType.attach.transaction:
            receivedAttached(jsonData)
        case SignalType.handle.transaction: break
        case SignalType.info.transaction: break
        case SignalType.keepalive.transaction: break
        default:
            print("unknown transaction message")
        }
    }
    
    private func receivedCreated(_ jsonData: JSON) {
        if let sessionId = jsonData["data"]["id"].int64 {
            sendJanusAttach(sessionId)
        }
    }
    
    private func receivedAttached(_ jsonData: JSON) {
        guard let sessionId = jsonData["session_id"].int64,
            let handleId = jsonData["data"]["id"].int64
            else { return }
        sendJanusHandle(sessionId: sessionId, handleId: handleId)
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
        
        let data = message.data(using: .utf8)!
        do {
            let jsonData = try JSON(data: data)
            parse(jsonData)
        } catch {
            print(error.localizedDescription)
        }
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
