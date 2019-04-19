//
//  SignalingClient.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/03/07.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import Foundation
import Starscream
import WebRTC

protocol SignalClientDelegate: AnyObject {
    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)
    func didReceiveMessage(_ signalClient: SignalingClient, message: String)
}

final class SignalingClient {
    private let socket: WebSocket
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    weak var delegate: SignalClientDelegate?

    init(serverUrl: URL, protocols: [String] = []) {
        if protocols.isEmpty {
            self.socket = WebSocket(url: serverUrl)
        } else {
            self.socket = WebSocket(url: serverUrl, protocols: protocols)
        }
    }
    func connect() {
        self.socket.delegate = self
        self.socket.connect()
    }

    func send(packet: [String: Any], completion: (() -> Void)? = nil) {
        print("send packet")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: packet)
            socket.write(data: jsonData, completion: completion)
        } catch {
            print("error send")
        }
    }

    func send(sdp rtcSdp: RTCSessionDescription) {
        print("send rtcSdp")
        let message = Message.sdp(SessionDescription(from: rtcSdp))
        do {
            let dataMessage = try self.encoder.encode(message)
            self.socket.write(data: dataMessage)
        } catch {
            debugPrint("Warning: Could not encode sdp: \(error)")
        }
    }

    func send(candidate rtcIceCandidate: RTCIceCandidate) {
        print("send rtcIceCandidate")
        let message = Message.candidate(IceCandidate(from: rtcIceCandidate))
        do {
            let dataMessage = try self.encoder.encode(message)
            self.socket.write(data: dataMessage)
        } catch {
            debugPrint("Warning: Could not encode candidate: \(error)")
        }
    }
}

extension SignalingClient: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocketDidConnect")
        self.delegate?.signalClientDidConnect(self)
    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        self.delegate?.signalClientDidDisconnect(self)
        // try to reconnect every two seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            debugPrint("Trying to reconnect to signaling server...")
            self.socket.connect()
        }
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("websocketDidReceiveData")
        let message: Message
        do {
            message = try self.decoder.decode(Message.self, from: data)
        } catch {
            debugPrint("Warning: Could not decode incoming message: \(error)")
            return
        }

        switch message {
        case .candidate(let iceCandidate):
            self.delegate?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
        case .sdp(let sessionDescription):
            self.delegate?.signalClient(self, didReceiveRemoteSdp: sessionDescription.rtcSessionDescription)
        }
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        self.delegate?.didReceiveMessage(self, message: text)
    }
}
