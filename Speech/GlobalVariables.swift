//
//  GlobalVariables.swift
//  Capgemini
//
//  Created by xavier green on 22/02/2017.
//  Copyright © 2017 xavier green. All rights reserved.
//

import Foundation
import UIKit

struct GlobalVariables {
    static var username: String = ""
    static var speaker1: String = ""
    static var speaker2: String = ""
    static var allowedCommands: [String] = ["Authentification","Enrôlements","Suivant","Retour","Terminer","Chez Cételem ma voix et mon mot de passe","Chez Cételem ma voix est mon mot de passe","Oui","Non"]
    static var base64image: String = ""
    static var voteImageId: Int = 0
    static var drawColor = UIColor.black
    static var lineSizeMultiplier: Double = 50
    
    static var pieuvreUsernames = [String]()
    
    static var operationsInOrder = [String]()
    static var namesInOrder = [String]()
    static var phrasesInOrder = [String]()
    
    static var words = Dictionary<String, Int>()
    static var wordCount = [Int]()
    static var idUsernameMatch = [[String](),[String]()]
}
