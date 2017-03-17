//
//  CustomButtons.swift
//  Capgemini
//
//  Created by Younes Belkouchi on 24/02/2017.
//  Copyright © 2017 xavier green. All rights reserved.
//

import UIKit

class CustomButtons: UIButton {
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let color = UIColor.white
        let disabledColor = color.withAlphaComponent(0.3)
        let backgroundColor = UIColor(colorLiteralRed: 36/255, green: 179/255, blue: 199/255, alpha: 1.0) //UIColor.white
        
        //TODO: Code for our button
//        self.layer.borderWidth = 1.0
//        self.layer.borderColor = color.cgColor
        self.setTitleColor(color, for: .normal)
        self.setTitleColor(disabledColor, for: .disabled)
        self.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.setTitle(self.titleLabel?.text?.capitalized, for: .normal)
        self.backgroundColor=backgroundColor
    }
}
