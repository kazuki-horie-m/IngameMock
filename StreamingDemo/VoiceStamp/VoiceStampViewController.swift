//
//  VoiceStampViewController.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/03/13.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import UIKit
import CoreML
import Speech
import RxCocoa
import RxSwift

class VoiceStampViewController: UIViewController {
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var speechLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let audioEngine = AVAudioEngine()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    
    @IBAction private func recordButtonTouchDown(sender: UIButton) {
        sender.backgroundColor = .green
        if !audioEngine.isRunning {
            try? startRecording()
        }
    }
    
    @IBAction private func recordButtonTouchUp(sender: UIButton) {
        sender.backgroundColor = .clear
        stopRecoding()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechRecognizer.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SFSpeechRecognizer.requestAuthorization { (status) in
            OperationQueue.main.addOperation {
                switch status {
                case .authorized:
                    break
                case .denied:
                    break
                case .restricted:
                    break
                case .notDetermined:
                    break
                }
            }
        }
    }
    
    private func startRecording() throws {
        refreshTask()
        
//        mixWithOthers
//        duckOthers
//        allowBluetooth
//        defaultToSpeaker
//        interruptSpokenAudioAndMixWithOthers
//        allowBluetoothA2DP
//        allowAirPlay
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: [.mixWithOthers])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest
            else { fatalError("Error: Request") }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] (result, error) in
            guard let `self` = self else { return }
            var isFinal = false
            
            if let result = result {
                self.speechLabel.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.stopRecoding()
                inputNode.removeTap(onBus: 0)
            }
        }
            
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        statusLabel.text = "Recognizing..."
    }
 
    private func stopRecoding() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recognitionRequest = nil
            recognitionTask = nil
            
            self.statusLabel.text = "Stop"
        }
    }
    
    private func refreshTask() {
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}

extension VoiceStampViewController: SFSpeechRecognizerDelegate {
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
    }
}
