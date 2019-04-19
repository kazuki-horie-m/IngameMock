//
//  MicVolumeObserver.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/03/22.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import AVFoundation

final class MicVolumeObserver: NSObject {
    private let captureSession = AVCaptureSession()
    let serialQueue = DispatchQueue(label: "MicVolumeObserver.serialqueue.audio")

    var updated: ((_ index: Int, _ average: Float, _ peak: Float) -> Void)?

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
        try? audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.mixWithOthers, .allowBluetooth, .allowBluetoothA2DP])
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        guard let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio) else { return }
        guard let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else { return }
        captureSession.addInput(audioInput)

        let audioDataOut = AVCaptureAudioDataOutput()
        audioDataOut.setSampleBufferDelegate(self, queue: serialQueue)
        captureSession.addOutput(audioDataOut)

    }
}

extension MicVolumeObserver: AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.audioChannels.enumerated().forEach { [unowned self] index, channel in
            let averagePowerLevel = channel.averagePowerLevel
            let peakHoldLevel = channel.peakHoldLevel
            self.updated?(index, averagePowerLevel, peakHoldLevel)
        }
    }
}
