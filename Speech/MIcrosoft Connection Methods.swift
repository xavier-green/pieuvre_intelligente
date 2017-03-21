//
//  MIcrosoft Connection Methods.swift
//  Speech
//
//  Created by Younes Belkouchi on 17/03/2017.
//  Copyright © 2017 Google. All rights reserved.
//

import Foundation

class Connection {
    private var Server: ConnectiontoBackServerMicrosoft!
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
    func createUser(speakerId: String) {
        Server.createUser(speakerId: speakerId)
        print("User added ")
    }
    
    func enrollCheck(speakerId: String) -> String {
        let dataString = Server.enrollCheck(speakerId: speakerId)
        let jsonData = parseJson(jsonString: dataString)
        return jsonData["status"] as! String
    }
    func getUsers() -> Array<String> {
        let usernamesJSON = Server.getUsersNames()
        let data: Data = usernamesJSON.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [AnyObject]
        var usernames = [String]()
        for object in json! {
            let name = object["username"]!
            if !usernames.contains(name as! String) {
                usernames.append(name as! String)
                GlobalVariables.idUsernameMatch[0].append(name as! String)
                GlobalVariables.idUsernameMatch[1].append(object["identificationProfile"]! as! String)
            }
        }
        return usernames as Array
    }
    
    func getSpeaker(operationUrl: String) -> String {
        let dataString = Server.checkUser(operationUrl: operationUrl)
        print(dataString)
        let jsonData = parseJson(jsonString: dataString)
        if let speaker = jsonData["username"] {
            return speaker as! String
        }
        else {return "Analysis still not finished"}
    }
    
        init() {
        Server = ConnectiontoBackServerMicrosoft()
    }
}
