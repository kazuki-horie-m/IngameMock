//
//  SignalingRoomClient.swift
//  StreamingDemo
//
//  Created by Kazuki Horie on 2019/03/16.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import Foundation
import SocketIO

class SignalingRoomClient {
    private lazy var manager: SocketManager = SocketManager(socketURL: Config.room.signalingServerUrl, config: [.log(true), .compress])
    private var socket: SocketIOClient {
        return manager.defaultSocket
    }
    
    func start() {
        socket.removeAllHandlers()
        
        setupListener()
        socket.connect()
        
    }
    
    func stop() {
        socket.disconnect()
    }
    
    private func setupListener() {
        let room = "room-1234"
        socket.on("connect") { [unowned self] data, ack in
            print("socket connected")
            self.socket.emit("enter", room);
        }
        
        socket.on("message") { [unowned self] data, ack in
            print("message:")
            guard let message = data[0] as? String else {
                return
            }
            print(message)
            
//            let fromId = message.from;
//
//            if (message.type === 'offer') {
//                // -- got offer ---
//                let offer = new RTCSessionDescription(message);
//                setOffer(fromId, offer);
//            }
//            else if (message.type === 'answer') {
//                // --- got answer ---
//                let answer = new RTCSessionDescription(message);
//                setAnswer(fromId, answer);
//            }
//            else if (message.type === 'candidate') {
//                // --- got ICE candidate ---
//                let candidate = new RTCIceCandidate(message.ice);
//                addIceCandidate(fromId, candidate);
//            }
//            else if (message.type === 'call me') {
//                if (! isReadyToConnect()) {
//                    console.log('Not ready to connect, so ignore');
//                    return;
//                }
//                else if (! canConnectMore()) {
//                    console.warn('TOO MANY connections, so ignore');
//                }
//
//                if (isConnectedWith(fromId)) {
//                    // already connnected, so skip
//                    console.log('already connected, so ignore');
//                }
//                else {
//                    // connect new party
//                    makeOffer(fromId);
//                }
//            }
//            else if (message.type === 'bye') {
//                if (isConnectedWith(fromId)) {
//                    stopConnection(fromId);
//                }
//            }
        }
        
        socket.on("user disconnected") { [unowned self] data, ack in
            print("user disconnected")
//            let id = evt.id;
//            if (isConnectedWith(id)) {
//                stopConnection(id);
//            }
        }
        
        socket.on("from_server") { data, ack in
            print("socket from_server:")
            if let msg = data[0] as? String {
                print(msg)
            }
        }
    }
}

