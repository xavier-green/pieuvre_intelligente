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
            recoVocale.enroll(speakerId: "youyoun")
            recoVocale.playRecording()
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
