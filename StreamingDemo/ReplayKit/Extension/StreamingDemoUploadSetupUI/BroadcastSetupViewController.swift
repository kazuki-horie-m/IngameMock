//
//  BroadcastSetupViewController.swift
//  StreamingDemoUploadSetupUI
//
//  Created by Kazuki Horie on 2019/03/21.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import ReplayKit

// info.plistのNSExtension配下に 〜NSExtensionPrincipalClass〜 とかいうのが含まれてるとダメなので消すこと！！！
class BroadcastSetupViewController: UIViewController {
    @IBAction private func buttonAction(sender: UIButton) {
        userDidFinishSetup()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // Call this method when the user has finished interacting with the view controller and a broadcast stream can start
    func userDidFinishSetup() {
        NSLog("[TCTC] userDidFinishSetup")
        //        // URL of the resource where broadcast can be viewed that will be returned to the application
        //        let broadcastURL = URL(string:"http://apple.com/broadcast/streamID")
        //
        //        // Dictionary with setup information that will be provided to broadcast extension when broadcast is started
        //        let setupInfo: [String : NSCoding & NSObjectProtocol] = ["broadcastName": "example" as NSCoding & NSObjectProtocol]
        //
        //        // Tell ReplayKit that the extension is finished setting up and can begin broadcasting
        //        self.extensionContext?.completeRequest(withBroadcast: broadcastURL!, setupInfo: setupInfo)

        let endpointURL: String = "rtmp://192.168.2.1:1935/live"
        //        let broadcastURL = URL(string: "http://localhost/hls/live.m3u8")!
        let broadcastURL = URL(string: endpointURL)!

        let setupInfo: [String: NSCoding & NSObjectProtocol] =  [
            "fromUI": "true" as NSString,
            "endpointURL": endpointURL as NSString,
            "streamName": "live" as NSString
        ]

        //        self.extensionContext?.completeRequest(
        //            withBroadcast: broadcastURL,
        //            broadcastConfiguration: broadcastConfiguration,
        //            setupInfo: setupInfo
        //        )
        self.extensionContext?.completeRequest(withBroadcast: broadcastURL, setupInfo: setupInfo)
    }

    func userDidCancelSetup() {
        let error = NSError(domain: "com.tctc.rinrin", code: -1, userInfo: nil)
        // Tell ReplayKit that the extension was cancelled by the user
        self.extensionContext?.cancelRequest(withError: error)
    }

}
