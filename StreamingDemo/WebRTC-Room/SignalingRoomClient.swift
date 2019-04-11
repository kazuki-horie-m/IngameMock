//
//  SignalingRoomClient.swift
//  StreamingDemo
//
//  Created by Kazuki Horie on 2019/03/16.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import Foundation
import SocketIO

// copy from https://github.com/mganeko/webrtcexpjp/blob/master/basic2016/multi.html
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
            AppLog.debug("socket connected")
            self.socket.emit("enter", room);
        }
        
        socket.on("message") { [unowned self] data, ack in
            AppLog.debug("message: ")
            guard let message = data[0] as? String else {
                return
            }
            AppLog.debug(message)
            
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
    
//    // --- broadcast message to all members in room
//    func emitRoom(msg: String) {
//        socket.emit("message", msg);
//    }
//
//    func emitTo(id: String, msg: String) {
//        msg.sendto = id;
//        socket.emit('message', msg);
//    }
//
//
//    // -- room名を取得 --
//    func getRoomName() { // たとえば、 URLに  ?r oomname  とする
//    let url = document.location.href;
//    let args = url.split('?');
//    if (args.length > 1) {
//    let room = args[1];
//    if (room != '') {
//    return room;
//    }
//    }
//    return '_testroom';
//    }
//    // ---- for multi party -----
//    function isReadyToConnect() {
//    if (localStream) {
//    return true;
//    }
//    else {
//    return false;
//    }
//    }
//    // --- RTCPeerConnections ---
//    function getConnectionCount() {
//    return peerConnections.length;
//    }
//    function canConnectMore() {
//    return (getConnectionCount() < MAX_CONNECTION_COUNT);
//    }
//
//
//    function isConnectedWith(id) {
//    if (peerConnections[id])  {
//    return true;
//    }
//    else {
//    return false;
//    }
//    }
//    function addConnection(id, peer) {
//    _assert('addConnection() peer', peer);
//    _assert('addConnection() peer must NOT EXIST', (! peerConnections[id]));
//    peerConnections[id] = peer;
//    }
//    function getConnection(id) {
//    let peer = peerConnections[id];
//    _assert('getConnection() peer must exist', peer);
//    return peer;
//    }
//    function deleteConnection(id) {
//    _assert('deleteConnection() peer must exist', peerConnections[id]);
//    delete peerConnections[id];
//    }
//    function stopConnection(id) {
//    detachVideo(id);
//    if (isConnectedWith(id)) {
//    let peer = getConnection(id);
//    peer.close();
//    deleteConnection(id);
//    }
//    }
//    function stopAllConnection() {
//    for (let id in peerConnections) {
//    stopConnection(id);
//    }
//    }

}

