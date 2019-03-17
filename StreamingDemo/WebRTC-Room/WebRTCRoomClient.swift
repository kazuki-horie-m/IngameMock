//
//  WebRTCRoomClient.swift
//  StreamingDemo
//
//  Created by Kazuki Horie on 2019/03/16.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import Foundation
import WebRTC

class WebRTCRoomClient: NSObject {
    private let MAX_CONNECTION_COUNT: Int = 3
    
    private let iceServers: [RTCIceServer]
    private var peerConnections: [String: RTCPeerConnection] = [:]
    
    override init() {
        fatalError("WebRTCClient:init is unavailable")
    }
    
    required init(iceServers: [String]) {
        let config = RTCConfiguration()
        self.iceServers = [RTCIceServer(urlStrings: iceServers)]
        
        // Unified plan is more superior than planB
        //TODO:        config.sdpSemantics = .unifiedPlan
        
        // gatherContinually will let WebRTC to listen to any network changes and send any new candidates to the other client
        config.continualGatheringPolicy = .gatherContinually
        
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil,
                                              optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue])
        
        super.init()
    }
    
    // --- RTCPeerConnections ---
    private func canConnectMore() -> Bool {
        return peerConnections.count < MAX_CONNECTION_COUNT
    }
    //
    private func isConnected(with identifier: String) -> Bool {
        return peerConnections[identifier] != nil
    }
    //
    private func addConnection(identifier: String, peer: RTCPeerConnection) {
        peerConnections[identifier] = peer;
    }
    
    private func getConnection(identifier: String) -> RTCPeerConnection? {
        return peerConnections[identifier]
    }
    
    private func deleteConnection(identifier: String) {
        peerConnections.removeValue(forKey: identifier)
    }
    
    // --- Video ---
    var renderers: [String: RTCMTLVideoView] = [:]
    private var remoteVideoTracks: [String: RTCVideoTrack] = [:]
    
    // --- video elements ---
    private func addRemoteVideoTrack(identifier: String, videoTrack: RTCVideoTrack?) {
        guard let renderer = renderers[identifier], let videoTrack = videoTrack
            else { return }
        videoTrack.add(renderer)
        remoteVideoTracks[identifier] = videoTrack
    }
    
    private func getRemoteVideoTrack(identifier: String) -> RTCVideoTrack? {
        return remoteVideoTracks[identifier]
    }
    
    private func deleteRemoteVideoTrack(identifier: String) {
        remoteVideoTracks.removeValue(forKey: identifier)
    }

    
    private func removeRenderer(identifier: String) {
        renderers.removeValue(forKey: identifier)
    }
    
    // video 連動
    // --- video elements ---
    private func attachVideoTrack(identifier: String, stream: RTCMediaStream) {
        addRemoteVideoTrack(identifier: identifier, videoTrack: stream.videoTracks.first);
    }
    
    private func detachVideo(identifier: String) {
        let video = getRemoteVideoTrack(identifier: identifier)
        if let renderer = renderers[identifier] {
            video?.remove(renderer)
        }
        deleteRemoteVideoTrack(identifier: identifier)
    }
    
    private func isRemoteVideoAttached(identifier: String) -> Bool {
        return remoteVideoTracks[identifier] != nil
    }
    
    // --- RTCPeerConnections ---
    private func stopConnection(identifier: String) {
        detachVideo(identifier: identifier);
        
        if (isConnected(with: identifier)) {
            let peer = getConnection(identifier: identifier)
            peer?.close();
            deleteConnection(identifier: identifier)
        }
    }
    
    private func stopAllConnection() {
        peerConnections.keys.forEach {
            stopConnection(identifier: $0)
        }
    }
}
