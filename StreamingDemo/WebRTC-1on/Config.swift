//
//  Config.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/03/07.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import Foundation

// Set this to the machine's address which runs the signaling server
fileprivate let defaultSignalingServerUrl = URL(string: "ws://192.168.2.101:3000")!
fileprivate let roomSignalingServerUrl = URL(string: "http://192.168.2.1:3002")!
//fileprivate let janusSignalingServerUrl = URL(string: "ws://192.168.2.1:8188")!
fileprivate let janusSignalingServerUrl = URL(string: "ws://192.168.2.101:8188")!
//fileprivate let defaultSignalingServerUrl = URL(string: "ws://10.196.42.175:8188")!

// We use Google's public stun servers. For production apps you should deploy your own stun/turn servers.
fileprivate let defaultIceServers = ["stun:stun.l.google.com:19302",
                                     "stun:stun1.l.google.com:19302",
                                     "stun:stun2.l.google.com:19302",
                                     "stun:stun3.l.google.com:19302",
                                     "stun:stun4.l.google.com:19302"]

struct Config {
    let signalingServerUrl: URL
    let webRTCIceServers: [String]
    
    static let `default` = Config(signalingServerUrl: defaultSignalingServerUrl, webRTCIceServers: defaultIceServers)
    static let janus     = Config(signalingServerUrl: janusSignalingServerUrl, webRTCIceServers: defaultIceServers)
    static let room     = Config(signalingServerUrl: roomSignalingServerUrl, webRTCIceServers: defaultIceServers)
}
