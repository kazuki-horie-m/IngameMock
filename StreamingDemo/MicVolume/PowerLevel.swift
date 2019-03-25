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
    
    var updated: ((Float, Float) -> Void)?
    
    override init() {
        super.init()
        setupCaptureRoute()
    }
    
    func setupCaptureRoute() {
        // OSがデフォルトにしているマイクデバイスを選ぶ
        let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
        
        // マイクデバイスをキャプチャセッションにつなぐ入力クラスを用意
        let audioInput = try! AVCaptureDeviceInput(device: audioDevice!)

        // マイク入力の出力先（今回はデータをデリゲートメソッドに渡す）を用意
        let audioDataOut = AVCaptureAudioDataOutput()
        // デリゲートオブジェクトを設定
        audioDataOut.setSampleBufferDelegate(self, queue: serialQueue)

        // キャプチャセッションに入出力を接続。これでいつでもstartできる
        captureSession.addInput(audioInput)
        captureSession.addOutput(audioDataOut)
    }
    
    func start() { captureSession.startRunning() }
    func stop() { captureSession.stopRunning() }
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
