//
//  WRTopViewController.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/03/06.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import UIKit
import WebRTC
import Starscream
import AVFoundation

class WRTopViewController: UIViewController {
    @IBOutlet private weak var videoView: RTCMTLVideoView!
    @IBOutlet private weak var cameraView: RTCMTLVideoView!//RTCCameraPreviewView!
    
    @IBOutlet private weak var webRTCStatusLabel: UILabel?
    
    private lazy var signalClient = SignalingClient(serverUrl: Config.default.signalingServerUrl)
    private lazy var webRTCClient = WebRTCClient(iceServers: Config.default.webRTCIceServers)
    
    private var signalingConnected: Bool = false
    
    private var hasLocalSdp: Bool = false
    private var hasRemoteSdp: Bool = false
    
    private var localCandidateCount: Int = 0
    private var remoteCandidateCount: Int = 0
    
    private var speakerOn: Bool = false
    private var mute: Bool = false
    
    @IBAction func offerButtonAction(_ sender: UIButton) {
        self.webRTCClient.offer { (sdp) in
            self.hasLocalSdp = true
            self.signalClient.send(sdp: sdp)
        }
    }
    
    @IBAction func receiveButtonAction(_ sender: UIButton) {
        self.webRTCClient.answer { (localSdp) in
            self.hasLocalSdp = true
            self.signalClient.send(sdp: localSdp)
        }
    }
    
    @IBAction func enableVideoAction(_ sender: UIButton) {
        self.webRTCClient.startCaptureLocalVideo(renderer: cameraView)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        webRTCClient.startCaptureLocalVideo(renderer: cameraView)
    }
}

extension WRTopViewController: SignalClientDelegate {
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
        print("didReceiveMessage: " + message)
    }
}

extension WRTopViewController: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("discovered local candidate")
        self.localCandidateCount += 1
        self.signalClient.send(candidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        
        let textColor: UIColor
        switch state {
        case .connected:
            print("[STATE] RTCIceConnectionState: connected")
            textColor = .green
            self.webRTCClient.renderRemoteVideo(to: videoView)
        case .completed:
            print("[STATE] RTCIceConnectionState: completed")
            textColor = .green
        case .disconnected:
            print("[STATE] RTCIceConnectionState: disconnected")
            textColor = .orange
        case .failed:
            print("[STATE] RTCIceConnectionState: failed")
            textColor = .red
        case .closed:
            print("[STATE] RTCIceConnectionState: closed")
            textColor = .red
        case .new:
            print("[STATE] RTCIceConnectionState: new:")
            textColor = .black
        case .checking:
            print("[STATE] RTCIceConnectionState: checking")
            textColor = .black
        case .count:
            print("[STATE] RTCIceConnectionState: count")
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

