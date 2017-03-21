//
//  NuanceButtonClass.swift
//  Capgemini
//
//  Created by xavier green on 27/02/2017.
//  Copyright © 2017 xavier green. All rights reserved.
//

import UIKit

class NuanceButtonClass: UIButton {
    
    var recoVocale: ReconnaissanceVocaleController!
    
    func recordTapped() {
        if recoVocale.isRecording() {
            recoVocale.finishRecording(success: true)
            if self.restorationIdentifier=="Register" {
                DispatchQueue.global(qos: .background).async {
                    self.recoVocale.enroll(speakerId: GlobalVariables.username)
                    DispatchQueue.main.async {
                        print("data sent")
                    }
                }
            } else if self.restorationIdentifier=="Identify"{
                DispatchQueue.global(qos: .background).async {
                    self.recoVocale.identify()
                    DispatchQueue.main.async {
                        print("data sent")
                    }
                }
            } else {
                print("this button has no callback function")
            }
        } else {
            recoVocale.startRecording()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        recoVocale = ReconnaissanceVocaleController()
        setStyle()
        self.addTarget(self, action: #selector(self.recordTapped), for: .touchUpInside)
    }
    
    
    func setStyle() {
        self.setTitle("RECORD BUTTON", for: .normal)
    }

}
