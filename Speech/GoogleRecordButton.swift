//
//  GoogleRecordButton.swift
//  Speech
//
//  Created by xavier green on 17/03/2017.
//  Copyright © 2017 Google. All rights reserved.
//

import UIKit
import AVFoundation
import googleapis

let SAMPLE_RATE = 16000

class GoogleRecordButton: UIButton, AudioControllerDelegate {
    
    var audioData: NSMutableData!
    var recording: Bool = false
    let micOffImage = UIImage(named: "micOff")
    let micOnImage = UIImage(named: "micOn")
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        AudioController.sharedInstance.delegate = self
        self.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        self.setTitle("", for: .normal)
        self.setBackgroundImage(micOnImage, for: .normal)
    }
    
    func buttonTapped() {
        if recording {
//            self.setTitle("START", for: .normal)
            self.setBackgroundImage(micOnImage, for: .normal)
            stopAudio()
            recording = false
            NotificationCenter.default.post(name: Notification.Name(rawValue: "PIEUVRE_START"), object: nil)
        } else {
//            self.setTitle("STOP", for: .normal)
            self.setBackgroundImage(micOffImage, for: .normal)
            recordAudio()
            recording = true
        }
    }

    func recordAudio() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
        } catch {
            
        }
        audioData = NSMutableData()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
        SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
        _ = AudioController.sharedInstance.start()
    }
    
    func stopAudio() {
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
    }
    
    func processSampleData(_ data: Data) -> Void {
        audioData.append(data)
        
        // We recommend sending samples in 100ms chunks
        let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
            * Double(SAMPLE_RATE) /* samples/second */
            * 2 /* bytes/sample */);
        
        if (audioData.length > chunkSize) {
            SpeechRecognitionService.sharedInstance.streamAudioData(audioData,
                                                                    completion:
                { [weak self] (response, error) in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    if let response = response {
                        var finished = false
                        var fullText = ""
                        // print(response)
                        for result in response.resultsArray! {
                            if let result = result as? StreamingRecognitionResult {
                                if result.isFinal {
                                    print(result.alternativesArray[0])
                                    fullText = (result.alternativesArray[0] as AnyObject).transcript
                                    finished = true
                                }
                            }
                        }
                        if (fullText != "") {
                            let resp = MicrosoftConnection().sentiment(sentence: fullText)
                            print("sentiment score:")
                            print(String(resp))
                            let sendData = [
                                String(resp),
                                fullText
                            ]
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "PIEUVRE_TEXT"), object: sendData)
                        }
                        if finished {
                            strongSelf.stopAudio()
                        }
                    }
            })
            self.audioData = NSMutableData()
        }
    }

}
