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
        print("broadcastStarted")
        super.broadcastStarted(withSetupInfo: setupInfo)
//        guard
//            let endpointURL: String = setupInfo?["endpointURL"] as? String,
//            let streamName: String = setupInfo?["streamName"] as? String else {
//                return
//        }
        let endpointURL: String = "rtmp://192.168.2.1:1935/live"
        let streamName: String = "live"
        broadcaster.streamName = streamName
        broadcaster.connect(endpointURL, arguments: nil)
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case .video:
            if let description: CMVideoFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
                let dimensions: CMVideoDimensions = CMVideoFormatDescriptionGetDimensions(description)
                broadcaster.stream.videoSettings = [
                    "width": dimensions.width,
                    "height": dimensions.height ,
                    "profileLevel": kVTProfileLevel_H264_Baseline_AutoLevel
                ]
            }
            broadcaster.appendSampleBuffer(sampleBuffer, withType: .video)
        case .audioApp:
            break
        case .audioMic:
            broadcaster.appendSampleBuffer(sampleBuffer, withType: .audio)
        }
    }
}
