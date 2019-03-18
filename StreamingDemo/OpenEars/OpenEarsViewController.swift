//
//  OpenEarsViewController.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/03/18.
//  Copyright © 2019年 Kazuki Horie. All rights reserved.
//

import UIKit

class OpenEarsViewController: UIViewController {
    @IBOutlet private weak var tfSay: UITextField!
    @IBOutlet private weak var lblRecognized: UILabel!
    
    var slt = Slt()
    var openEarsEventsObserver = OEEventsObserver()
    var fliteController = OEFliteController()
    
    @IBAction private func sayAction(sender: UIButton) {
        self.fliteController.say(_:"\(tfSay.text!)", with:self.slt)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.openEarsEventsObserver.delegate = self
        
        let languageModelGenerator = OELanguageModelGenerator()
        
        let firstLanguageArray = ["wo",
                                  "e-yo",
                                  "aaaa",
                                  "ekei"
                                  ]
        
        let firstVocabularyName = "FirstVocabulary"
        
        let firstLanguageModelGenerationError: Error! = languageModelGenerator.generateLanguageModel(from: firstLanguageArray, withFilesNamed: firstVocabularyName, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"))
        
        if(firstLanguageModelGenerationError != nil) {
            print("Error while creating initial language model: \(firstLanguageModelGenerationError)")
        }
        
        let pathToFirstDynamicallyGeneratedLanguageModel = languageModelGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: firstVocabularyName)
        let pathToFirstDynamicallyGeneratedDictionary = languageModelGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: firstVocabularyName)
        
        OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
    }
}

extension OpenEarsViewController: OEEventsObserverDelegate {
    func pocketsphinxDidReceiveHypothesis(_ hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        print("Local callback: The received hypothesis is \(hypothesis!) with a score of \(recognitionScore!) and an ID of \(utteranceID!)") // Log it.
        
        lblRecognized.text = "Heard: \"\(hypothesis!)\""
        
        // This is how to use an available instance of OEFliteController. We're going to repeat back the command that we heard with the voice we've chosen.
        self.fliteController.say(_:"updated", with:self.slt)
    }
}
