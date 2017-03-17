//
//  RecordButtonClass.swift
//  Capgemini
//
//  Created by xavier green on 24/02/2017.
//  Copyright © 2017 xavier green. All rights reserved.
//

import UIKit
import AVFoundation

class RecordButtonClass: UIButton {
    
    //var recoVocale: ReconnaissanceVocaleController!
    var micToText = SpeechToText()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setStyle()
        start()
    }
    
    func setStyle() {
        self.setTitle("", for: .normal)
    }
    
    func start() {
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            switch authStatus {
            case .authorized:
                self.isHidden = false
                self.addTarget(self, action: #selector(self.recordTapped), for: .touchDown)
                self.addTarget(self, action: #selector(self.recordTapped), for: .touchUpInside)
                self.addTarget(self, action: #selector(self.recordTapped), for: .touchDragExit)
                print("all okay")
                
            case .denied:
                self.isHidden = true
                print("User denied access to speech recognition")
                
            case .restricted:
                self.isHidden = true
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                self.isHidden = true
                print("Speech recognition not yet authorized")
            }
        }
    }
    
    
    func recordTapped() {
        if micToText.isRecording() {
            NSLog("Stopping recording")
            micToText.stop()
            //recoVocale.finishRecording(success: true)
            self.setBackgroundImage(micOnImage, for: .normal)
        } else {
            NSLog("Starting recording")
            self.setBackgroundImage(micOffImage, for: .normal)
            micToText.startRecording()
        }
    }
    
}
