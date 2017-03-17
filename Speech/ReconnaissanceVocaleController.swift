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
        
        //On initialise le serveur de nuance qui fera les vérifications / enrollement
        Server = ServerFunctions()
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
        ]
        
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
    
    /* Fonction d'authentification d'une personne avec Nuance
    Parametres:
        - username: pseudo de la personne à authentifier
        - fileUrl (accessible dans la classe): fichier son à convertir en base64 puis envoyer à Nuance
    Retour:
        - Boolean: true/false
    */
    func verify(username: String) -> Bool {
        let base64data = NSData(contentsOf: fileUrl)?.base64EncodedString()
        return Server.verify(username: username, audio: base64data!.RFC3986UnreservedEncoded)
    }
    
    /* Fonction d'enrollement d'une personne avec Nuance
     Parametres:
     - username: pseudo de la personne à authentifier
     - fileUrl (accessible dans la classe): fichier son à convertir en base64 puis envoyer à Nuance
     Retour:
     - String: représente où Nuance en est de l'enrollement (si le son etait okay, si l'enrollement est en cours / terminé)
     */
    func enroll(username: String) -> String {
        let base64data = NSData(contentsOf: fileUrl)?.base64EncodedString()
        return Server.enroll(username: username, audio: base64data!.RFC3986UnreservedEncoded)
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
