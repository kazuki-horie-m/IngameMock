//
//  SampleHandler.swift
//  StreamingDemoUpload
//
//  Created by Kazuki Horie on 2019/03/21.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import ReplayKit
import HaishinKit
import VideoToolbox

class SampleHandler: RPBroadcastSampleHandler {
    private var broadcaster = RTMPBroadcaster()

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        NSLog("[TCTC] SampleHandler broadcastStarted")
        super.broadcastStarted(withSetupInfo: setupInfo)
        
//        if setupInfo?["fromUI"] as? String != "true" {
//            let userInfo = [NSLocalizedFailureReasonErrorKey : "Not From UI"]
//            let error = NSError(domain: "RPBroadcastErrorDomain", code: 401, userInfo: userInfo)
//            finishBroadcastWithError(error)
//        }
        
//        guard
//            let endpointURL: String = setupInfo?["endpointURL"] as? String,
//            let streamName: String = setupInfo?["streamName"] as? String else {
//                return
//        }
//        let endpointURL: String = "rtmp://192.168.2.1:1935/live"
        let endpointURL: String = "rtmp://liveencoder:wowza13mixi@18.182.65.36:1935/live"
        let streamName: String = "myStream"
        broadcaster.streamName = streamName
        broadcaster.connect(endpointURL, arguments: nil)
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
        NSLog("[TCTC] SampleHandler broadcastPaused")
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
        NSLog("[TCTC] SampleHandler broadcastResumed")
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
        NSLog("[TCTC] SampleHandler broadcastFinished")
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case .video:
            if let description: CMVideoFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
                let dimensions: CMVideoDimensions = CMVideoFormatDescriptionGetDimensions(description)
                broadcaster.stream.videoSettings = [
                    "width": dimensions.width,
                    "height": dimensions.height,
                    "profileLevel": kVTProfileLevel_H264_Baseline_AutoLevel,
                    "maxKeyFrameIntervalDuration": 0.5
                ]
            }
            broadcaster.appendSampleBuffer(sampleBuffer, withType: .video)
        case .audioApp:
            broadcaster.appendSampleBuffer(sampleBuffer, withType: .audio)
        case .audioMic:
//            broadcaster.appendSampleBuffer(sampleBuffer, withType: .audio)
            break
        }
    }
}
