//
//  PowerLevel.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/03/22.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import AVFoundation

final class PowerLevel: NSObject {
    private let captureSession = AVCaptureSession()
    let serialQueue = DispatchQueue(label: "PowerLevel.serialqueue.audio")
    
    weak var updated: ((Float, Float) -> Void)?
    
    override init() {
        super.init()
        setupCaptureRoute()
    }
    
    
    func start() { captureSession.startRunning() }
    func stop() { captureSession.stopRunning() }
    
    func setupCaptureRoute() {
        captureSession.usesApplicationAudioSession = true
        captureSession.automaticallyConfiguresApplicationAudioSession = false
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.mixWithOthers, .allowBluetooth, .allowBluetoothA2DP])
        try! audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
        let audioInput = try! AVCaptureDeviceInput(device: audioDevice!)
        captureSession.addInput(audioInput)
        
        let audioDataOut = AVCaptureAudioDataOutput()
        audioDataOut.setSampleBufferDelegate(self, queue: serialQueue)
        captureSession.addOutput(audioDataOut)
        
    }
}

// デリゲートメソッドの用意
extension PowerLevel: AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let audioChannels = connection.audioChannels
        
        print("[TCTC] count: \(audioChannels.count)")
        audioChannels.forEach {
            let ave = $0.averagePowerLevel
            let peak = $0.peakHoldLevel
            print("[TCTC] ave: \(ave), peak: \(peak)\n")
        }
        
        guard audioChannels.count > 0 else { return }
        let averagePowerLevel = audioChannels.reduce(0.0){ $0 + $1.averagePowerLevel }
            / Float(audioChannels.count)
        let peakHoldLevel = audioChannels.reduce(0.0){ $0 + $1.peakHoldLevel }
            / Float(audioChannels.count)
        updated?(averagePowerLevel, peakHoldLevel)
    }
}
