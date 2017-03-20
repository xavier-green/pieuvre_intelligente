//
//  ServerFunctions.swift
//  Capgemini
//
//  Created by xavier green on 27/02/2017.
//  Copyright © 2017 xavier green. All rights reserved.
//
import Foundation

class ServerFunctions {
    
    private var Server: ServerConnection!
    private var Parser: NuanceXMLParser!
    private var currentUsername: String = ""
    private var status: String = ""
    private var lastMissingSegments: Int = 3
    
    func getUserList() -> [String] {
        print("Getting user list")
        let userList = Server.getUserList()
        return Parser.extractUsers(xmlString: userList)
    }
    
    func verify(username: String, audio: String) -> Bool {
        let verification = Server.verify(speakerId: username, audio: audio)
        return Parser.extractMatch(xmlString: verification)
    }
    
    func getScore(username: String, audio: String) -> Int {
        let verification = Server.verify(speakerId: username, audio: audio)
        return Parser.extractScore(xmlString: verification)
    }
    
    func enroll(username: String, audio: String) -> String {
        self.currentUsername = username
        let statusXML = Server.enroll(speakerId: username, audio: audio)
        let status = Parser.extractUserStatus(xmlString: statusXML)
        let missingSegmentsXML = Server.getEnrollSegmentsStatus(speakerId: username)
        let missingSegments = Parser.extractMissingSegments(xmlString: missingSegmentsXML)
        var stringToReturn = String()
        if (status == "NotReady") {
            if (missingSegments >= self.lastMissingSegments) {
                print("Fail during audio recording")
                stringToReturn = "REC_FAIL"
            } else {
                self.lastMissingSegments = missingSegments
                print("Success, please record your voice again")
                stringToReturn = "REC_SUCCESS"
            }
        } else if (status == "Trained") {
            print("Successfully signed up !")
            stringToReturn = "SUCCESS"
        }
        return stringToReturn
    }
    
    init() {
        
        Server = ServerConnection()
        Parser = NuanceXMLParser()
        
    }
        
}

