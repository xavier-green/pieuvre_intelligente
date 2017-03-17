//
//  NuanceButtonClass.swift
//  Capgemini
//
//  Created by xavier green on 27/02/2017.
//  Copyright © 2017 xavier green. All rights reserved.
//

import UIKit
import Speech

class NuanceButtonClass: UIButton {
    
    var recoVocale: ReconnaissanceVocaleController!
    let micOffImage = UIImage(named: "micOff")
    let micOnImage = UIImage(named: "micOn")
    
    func recordTapped() {
        if recoVocale.isRecording() {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "NUANCE_PROCESSING"), object: self)
            self.setBackgroundImage(micOnImage, for: .normal)
            recoVocale.finishRecording(success: true)
            print("username:",GlobalVariables.username)
            if self.restorationIdentifier=="Login" {
                print("nuance button doing LOGIN functions")
                self.verify()
            } else if self.restorationIdentifier=="Register"{
                print("nuance button doing REGISTER functions")
                self.enroll()
            } else {
                print("this button has no callback function")
            }
        } else {
            self.setBackgroundImage(micOffImage, for: .normal)
            recoVocale.startRecording()
        }
    }
    
    func verify() {
        let username = GlobalVariables.username
        DispatchQueue.global(qos: .background).async {
            print("Running nuance fetch in background thread")
            let verified = self.recoVocale.verify(username: username)
            var notifString = String()
            if verified==true {
                notifString = "REC_SUCCESS"
            } else {
                notifString = "REC_FAIL"
            }
            DispatchQueue.main.async {
                print("back to main")
                print("nuance sending notif "+notifString)
                NotificationCenter.default.post(name: Notification.Name(rawValue: notifString), object: self)
            }
        }
    }
    
    func enroll() {
        let username = GlobalVariables.username
        DispatchQueue.global(qos: .background).async {
            print("Running nuance fetch in background thread")
            let notifString = self.recoVocale.enroll(username: username)
            DispatchQueue.main.async {
                print("back to main")
                print("nuance sending notif "+notifString)
                NotificationCenter.default.post(name: Notification.Name(rawValue: notifString), object: self)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        recoVocale = ReconnaissanceVocaleController()
        setStyle()
        start()
    }
    
    func setStyle() {
        self.setBackgroundImage(micOnImage, for: .normal)
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

}
