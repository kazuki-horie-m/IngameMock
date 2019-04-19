//
//  RTMPBroadcaster.swift
//  StreamingDemoUpload
//
//  Created by Kazuki Horie on 2019/03/21.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import AVFoundation
import CoreMedia
import HaishinKit

public class RTMPBroadcaster: RTMPConnection {
    public var streamName: String?

    public lazy var stream: RTMPStream = {
        RTMPStream(connection: self)
    }()

    private var connecting: Bool = false
    private let lockQueue = DispatchQueue(label: "com.tctc.HaishinKit.RTMPBroadcaster.lock")

    override public init() {
        super.init()
        addEventListener(Event.RTMP_STATUS, selector: #selector(rtmpStatusEvent), observer: self)
    }

    deinit {
        removeEventListener(Event.RTMP_STATUS, selector: #selector(rtmpStatusEvent), observer: self)
    }

    override public func connect(_ command: String, arguments: Any?...) {
        lockQueue.sync {
            //            if connecting {
            //                NSLog("[TCTC] cancel connect command: \(command)")
            //                return
            //            }
            connecting = true
            NSLog("[TCTC] execute connect command: \(command)")
            super.connect(command, arguments: arguments)
        }
    }

    func appendSampleBuffer(_ sampleBuffer: CMSampleBuffer, withType: AVMediaType, options: [NSObject: AnyObject]? = nil) {
        stream.appendSampleBuffer(sampleBuffer, withType: withType)
    }

    override public func close() {
        lockQueue.sync {
            self.connecting = false
            super.close()
        }
    }

    @objc
    func rtmpStatusEvent(_ status: Notification) {
        let e = Event.from(status)
        guard
            let data: ASObject = e.data as? ASObject,
            let code: String = data["code"] as? String,
            let streamName: String = streamName else {
                NSLog("[TCTC] rtmpStatusEvent Empty")
                return
        }

        NSLog("[TCTC] rtmpStatusEvent code: \(code)")

        switch code {
        case RTMPConnection.Code.connectSuccess.rawValue:
            stream.publish(streamName)
        case RTMPConnection.Code.connectRejected.rawValue:
            guard
                let uri: URL = uri,
                let user: String = uri.user,
                let password: String = uri.password,
                let description: String = data["description"] as? String else {
                    break
            }
            NSLog("[TCTC] description: \(description)")
            switch true {
            case description.contains("nosuchuser"):
                break
            case description.contains("authfailed"):
                break
            case description.contains("need auth"):
                let command: String = RTMPBroadcaster.createSanJoseAuthCommand(uri, description: description)
                connect(command, arguments: nil)
            case description.contains("authmod=adobe"):
                if user.isEmpty || password.isEmpty {
                    //                    close(isDisconnected: true)
                    break
                }
                let query: String = uri.query ?? ""
                let command: String = uri.absoluteString + (query.isEmpty ? "?" : "&") + "authmod=adobe&user=\(user)"
                self.connect(command, arguments: nil)
            default:
                break
            }
        case RTMPConnection.Code.connectClosed.rawValue:
            if let description: String = data["description"] as? String {
                //                logger.warn(description)
            }
        //            self.close(isDisconnected: true)
        default:
            break
        }
    }

    private static func createSanJoseAuthCommand(_ url: URL, description: String) -> String {
        var command: String = url.absoluteString

        guard let index: String.Index = description.index(of: "?") else {
            return command
        }

        let query = String(description[description.index(index, offsetBy: 1)...])
        let challenge = String(format: "%08x", arc4random())
        let dictionary: [String: String] = URL(string: "http://localhost?" + query)!.dictionaryFromQuery()

        var response: String = MD5.base64("\(url.user!)\(dictionary["salt"]!)\(url.password!)")
        if let opaque: String = dictionary["opaque"] {
            command += "&opaque=\(opaque)"
            response += opaque
        } else if let challenge: String = dictionary["challenge"] {
            response += challenge
        }

        response = MD5.base64("\(response)\(challenge)")
        command += "&challenge=\(challenge)&response=\(response)"

        return command
    }
}
