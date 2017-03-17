//
//  MIcrosoft Connection Methods.swift
//  Speech
//
//  Created by Younes Belkouchi on 17/03/2017.
//  Copyright © 2017 Google. All rights reserved.
//

import Foundation

class Connection {
    private var Server: ConnectiontoBackServer!
    private var currentUsername: String = ""
    
    
    //MARK: JsonParser
    
    // Parse Json when it starts with []
    func parseJsonArray(jsonString: String) -> [AnyObject]  {
        let data: Data = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        let array = json as! [AnyObject]
        return array
    }
    
    // Parse Json when it starts with {}
    func parseJson(jsonString: String) -> [String:Any]  {
        let data: Data = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        let dictionary = json as! [String:Any]
        return dictionary
    }
    
    
    //MARK: Requests Executed
    
    /**
     Gets all users name in back database
     Parses Json from request
     - Returns:
     - sendData : [usernames, usernamesAuths]
     - usernames: [String] of users names
     - usernamesAuths: [Int] of users authentication number
     */
    func createUser(speakerId: String) -> String {
        let userJSON = Server.createUser(speakerId: speakerId)
        print("User added :",userJSON)
        return userJSON
    }
    
        init() {
        Server = ConnectiontoBackServer()
    }
}
