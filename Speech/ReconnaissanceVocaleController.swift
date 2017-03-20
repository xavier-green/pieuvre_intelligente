//
//  ReconnaissanceVocaleController.swift
//  Capgemini
//
//  Created by xavier green on 20/02/2017.
//  Copyright © 2017 xavier green. All rights reserved.
//

import Foundation
import AVFoundation

class ReconnaissanceVocaleController {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var Server : ServerFunctions!
    private var fileUrl : URL!
    
    var recordingOkay: Bool = false
    
    init() {
        print("App started")
        recordingSession = AVAudioSession.sharedInstance()
        Server = ServerFunctions()
        
        //On initialise le serveur de nuance qui fera les vérifications / enrollement
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingOkay = true
            //return true
        } catch {
            //return false
        }
    }
    
    //Retourne l'emplacement du fichier audio enregistré
    func getURL() -> URL {
        return fileUrl
    }
    
    //Teste si l'on est ou non en train d'enregistrer une voix
    func isRecording() -> Bool {
        if (self.audioRecorder == nil) {
            print("IS NOT RECORDING")
            return false
        } else {
            print("IS RECORDING")
            return true
        }
    }
    
    func getScore(username: String) -> Int {
        let base64data = NSData(contentsOf: fileUrl)?.base64EncodedString()
        let score = Server.getScore(username: username, audio: base64data!.RFC3986UnreservedEncoded)
        return score
    }
    
    // Début d'enregistrement
    func startRecording() {
        
        // Obtenir l'emplacement du fichier son
        fileUrl = self.directoryURL()! as URL
        
        // Parametres d'encodage compatibles avec Nuance
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 8000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ] as [String : Any]
        
        if self.recordingOkay {
            
            print("currently recording...")
            
            
            do {
                audioRecorder = try AVAudioRecorder(url: fileUrl, settings: settings)
                audioRecorder.record()
            } catch {
                // Si il y a une erreur dans l'enregistrement, on force la fin de l'enregistrement avec un flag d'erreur
                self.finishRecording(success: false)
            }
            
        }
    }
    
    func finishRecording(success: Bool) {
        print("finished recording !")
        audioRecorder.stop()
        audioRecorder = nil
    }
    func enroll(speakerId: String) {
        ConnectiontoBackServerMicrosoft().enroll(speakerId: speakerId, fileUrl: fileUrl)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    // Enregistrement temporaire du fichier audio avant conversion
    func directoryURL() -> NSURL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent("recording.wav")
        print(soundURL!)
        return soundURL as NSURL?
    }
    
    func playRecording() {
        self.audioPlayer = try! AVAudioPlayer(contentsOf: fileUrl)
        self.audioPlayer.prepareToPlay()
        self.audioPlayer.play()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print(flag)
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?){
        print(error.debugDescription)
    }
    internal func audioPlayerBeginInterruption(_ player: AVAudioPlayer){
        print(player.debugDescription)
    }
    
}
