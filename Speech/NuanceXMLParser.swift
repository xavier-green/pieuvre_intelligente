//
//  NuanceXMLParser.swift
//  Capgemini
//
//  Created by xavier green on 27/02/2017.
//  Copyright © 2017 xavier green. All rights reserved.
//

import Foundation
import AEXML

class NuanceXMLParser {
    
    init() {
        
        print("Initialising xml nuance parser")
        
    }
    
    func extractSpeaker(xmlString: String) -> String {
        
        let xmlData = xmlString.data(using: String.Encoding.utf8)!
        
        do {
            let xmlDoc = try AEXMLDocument(xml: xmlData)
            let speakerId = xmlDoc.root["SpeakerId"].value
            //print(speakerId ?? "No speakerId found")
            return speakerId!
        } catch {
            print("field speakerId not found")
            return ""
        }
        
    }
    
    func extractUserStatus(xmlString: String) -> String {
        
        let xmlData = xmlString.data(using: String.Encoding.utf8)!
        
        do {
            let xmlDoc = try AEXMLDocument(xml: xmlData)
            let status = xmlDoc.root.value
            print("status is: ",status ?? "no status")
            return status!
        } catch {
            print("status not found")
            return ""
        }
        
    }
    
    func extractUsers(xmlString: String) -> [String] {
        
        let xmlData = xmlString.data(using: String.Encoding.utf8)!
        var allUsers: [String] = []
        
        do {
            let xmlDoc = try AEXMLDocument(xml: xmlData)
            if let users = xmlDoc.root["string"].all {
                for user in users {
                    if let username = user.value {
                        allUsers.append(username)
                    }
                }
            }
            return allUsers
        } catch {
            print("status not found")
            return [""]
        }
        
    }
    
    func extractMissingSegments(xmlString: String) -> Int {
        
        let xmlData = xmlString.data(using: String.Encoding.utf8)!
        
        do {
            let xmlDoc = try AEXMLDocument(xml: xmlData)
            let status = xmlDoc.root["MissingSegments"].value
            print("status is: ",status ?? "no status")
            return Int(status!)!
        } catch {
            print("status not found")
            return 0
        }
        
    }
    
    func extractMatch(xmlString: String) -> Bool {
        
        let xmlData = xmlString.data(using: String.Encoding.utf8)!
        
        do {
            let xmlDoc = try AEXMLDocument(xml: xmlData)
            let score = Int(xmlDoc.root["SpeakerResults"]["SpeakerResult"]["BiometricScore"].value!)!
            let isMatch = score > 30
            print("is user matched: ",isMatch," biometric score: ",score)
            return isMatch
        } catch {
            print("field Decision not found")
            return false
        }
        
    }
    
    func extractScore(xmlString: String) -> Int {
        
        let xmlData = xmlString.data(using: String.Encoding.utf8)!
        
        do {
            let xmlDoc = try AEXMLDocument(xml: xmlData)
            let score = Int(xmlDoc.root["SpeakerResults"]["SpeakerResult"]["BiometricScore"].value!)!
            return score
        } catch {
            print("field Decision not found")
            return 0
        }
        
    }
    
}
