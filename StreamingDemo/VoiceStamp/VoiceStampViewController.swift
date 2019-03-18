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

class VoiceStampViewController: UIViewController {
    @IBOutlet private weak var outputLabel: UILabel!
    
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let audioEngine = AVAudioEngine()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    
    @IBAction private func button1Action(sender: UIButton) {
        if !audioEngine.isRunning {
            do {
                try startAppleSpeechRecording()
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction private func button2Action(sender: UIButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
    }
    
    @IBAction private func button3Action(sender: UIButton) {
        
    }
    
    @IBAction private func button4Action(sender: UIButton) {
        
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
    
    private func startAppleSpeechRecording() throws {
//        端末ごとの音声認識回数には制限がある
//        アプリごとにも認識回数に制限がある
//        一回のディクテーション時間のMaxは1分
        
        if let recognitionTask = recognitionTask {
            // 既存タスクがあればキャンセル
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
//        mixWithOthers
//        duckOthers
//        allowBluetooth
//        defaultToSpeaker
//        interruptSpokenAudioAndMixWithOthers
//        allowBluetoothA2DP
//        allowAirPlay
        
        let audioSession = AVAudioSession.sharedInstance()
//        try audioSession.setCategory(AVAudioSession.Category.record)
//        try audioSession.setMode(AVAudioSession.Mode.measurement)
        try audioSession.setCategory(.record, mode: .measurement, options: [.mixWithOthers])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest
            else { fatalError("Error: Request") }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [unowned self] (result, error) in
            var isFinal = false
            
            if let result = result {
                self.outputLabel.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
            
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        outputLabel.text = "Recognizing..."
    }
    
}

extension VoiceStampViewController: SFSpeechRecognizerDelegate {
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
    }
}
