//
//  ServerConnection.swift
//  Capgemini
//
//  Created by xavier green on 27/02/2017.
//  Copyright © 2017 xavier green. All rights reserved.
//
import Foundation

class ServerConnection {
    
    init() {
        print("Initialising nuance server connection")
    }
    
    private let BASE_URL: String = "http://82.80.219.196"
    private let SERVER_USERNAME: String = "Capgemini"
    private let SERVER_PASSWORD: String = "12345678"
    private let SCOPE: String = "CAPGEMINI"
    private let VOICE_PRINT_TAG: String = "Mobile"
    private let CONFIG_SET_NAME: String = "Capgemini"
    
    private var resultData: String = ""
    
    func connectToServer(url: String, params: [[String]], method: String, notificationString: String) -> String {
        
        if method=="GET" {
            
            let connectionUrl = constructURL(base: BASE_URL, url: url, params: params)
            return getRequest(connectionUrl: connectionUrl, notificationString: notificationString)
            
        } else if method=="POST" {
            
            return postRequest(connectionUrl: BASE_URL+url, params: params, notificationString: notificationString)
            
        }
        
        return ""
        
    }
    
    func getRequest(connectionUrl: String, notificationString: String) -> String {
        
        print("Connecting to ",connectionUrl)
        
        let config = URLSessionConfiguration.default
        let authString = constructHeaders()
        config.httpAdditionalHeaders = ["Authorization" : authString]
        let session = URLSession(configuration: config)
        let url = URL(string: connectionUrl)!
        let request = URLRequest(url: url)
        
        return sendRequest(session: session, request: request, notificationString: notificationString)
        
    }
    
    func postRequest(connectionUrl: String, params: [[String]], notificationString: String) -> String {
        
        print("Connecting to ",connectionUrl)
        
        let postParams = constructParams(params: params)
        let sendData = postParams.data(using: String.Encoding.utf8)
        
        //print(postParams)
        
        let config = URLSessionConfiguration.default
        let authString = constructHeaders()
        config.httpAdditionalHeaders = ["Authorization" : authString]
        let session = URLSession(configuration: config)
        let url = URL(string: connectionUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = sendData
        
        return sendRequest(session: session, request: request, notificationString: notificationString)
        
    }
    
    func sendRequest(session: URLSession, request: URLRequest, notificationString: String) -> String {
        
        print("sending request")
        
        let semaphore = DispatchSemaphore(value: 0)
        var dataString: String?
        var errors: String?
        
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            if error != nil {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ERROR"), object: errors)
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                //print("response = \(response)")
                print("******** REQUEST ERROR")
                errors = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as? String
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ERROR"), object: errors)
                return
            }
            dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as? String
            //print(dataString)
            
            semaphore.signal()
            
            print("Done, sending notification: ",notificationString)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: notificationString), object: dataString)
            
        }).resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        if let error = errors {
            print(error)
        }
        
        return dataString!
        
    }
    
    func constructHeaders() -> String {
        
        let loginString = String(format: "%@:%@", SERVER_USERNAME, SERVER_PASSWORD)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        let authString = "Basic \(base64LoginString)"
        return authString
        
    }
    
    func constructURL(base: String, url: String, params: [[String]]) -> String {
        
        var finalUrl = base + url + "?"
        for param in params {
            finalUrl += param[0]+"="+param[1]+"&"
        }
        return finalUrl
        
    }
    
    func constructParams(params: [[String]]) -> String {
        
        var finalUrl = ""
        for param in params {
            finalUrl += param[0]+"="+param[1]+"&"
        }
        return finalUrl
        
    }
    
    func getUserList() -> String {
        
        let url: String = "/vocalpassword/vocalpasswordmanager.asmx/GetSpeakersList"
        let params: [[String]] = [["configSetName",CONFIG_SET_NAME],["maxSpeakers","500"]]
        
        return connectToServer(url: url, params: params, method: "GET", notificationString: "USER_LIST")
        
    }
    
    func isUserTrained(speakerId: String) -> String {
        
        let url: String = "/vocalpassword/vocalpasswordserver.asmx/IsTrained"
        let params: [[String]] = [["sessionId","0"],["speakerId",speakerId],["configSetName",CONFIG_SET_NAME],["voiceprintTag",VOICE_PRINT_TAG]]
        
        return connectToServer(url: url, params: params, method: "GET", notificationString: "USER_TRAINED")
        
    }
    
    func deleteAllEnrollSegment(speakerId: String) -> String {
        
        let url: String = "/vocalpassword/vocalpasswordserver.asmx/DeleteAllEnrollSegments"
        let params: [[String]] = [["sessionId","0"],["speakerId",speakerId],["configSetName",CONFIG_SET_NAME],["voiceprintTag",VOICE_PRINT_TAG]]
        
        return connectToServer(url: url, params: params, method: "GET", notificationString: "DELETE_ALL_ENROLL_SEGMENT")
        
    }
    
    func enroll(speakerId: String, audio: String) -> String {
        
        print("Nuance server enrollment")
        //print(audio)
        
        let url: String = "/VocalPassword/VocalPasswordServer.asmx/Enroll"
        let params: [[String]] = [["sessionId","0"],["speakerId",speakerId],["configSetName",CONFIG_SET_NAME],["voiceprintTag",VOICE_PRINT_TAG],["text","null"],["audio",audio]]
        
        return connectToServer(url: url, params: params, method: "POST", notificationString: "ENROLL")
        
    }
    
    func verify(speakerId: String, audio: String) -> String {
        
        print("Nuance server verification")
        
        let url: String = "/VocalPassword/VocalPasswordServer.asmx/Verify"
        let params: [[String]] = [["sessionId","0"],["speakerId",speakerId],["configSetName",CONFIG_SET_NAME],["voiceprintTag",VOICE_PRINT_TAG],["text","null"],["audio",audio]]
        
        return connectToServer(url: url, params: params, method: "POST", notificationString: "VERIFY")
        
    }
    
    func getConfigurationSetList() -> String {
        
        let url: String = "/VocalPassword/VocalPasswordManager.asmx/GetConfigurationSetList"
        let params: [[String]] = [["configSetName",SCOPE],["type","ConfigurationSet"]]
        
        return connectToServer(url: url, params: params, method: "GET", notificationString: "CONFIGURATION_SET_LIST")
        
    }
    
    func createSpeaker(sessionId: String, speakerId: String) -> String {
        
        let url: String = "/vocalpassword/vocalpasswordserver.asmx/CreateSpeaker"
        let params: [[String]] = [["sessionId",sessionId],["speakerId",speakerId],["configSetName",CONFIG_SET_NAME]]
        
        return connectToServer(url: url, params: params, method: "GET", notificationString: "CREATE_SPEAKER")
        
    }
    
    func getEnrollSegmentsStatus(speakerId: String) -> String {
        
        let url: String = "/vocalpassword/vocalpasswordserver.asmx/GetEnrollSegmentsStatus"
        let params: [[String]] = [["sessionId","0"],["speakerId",speakerId],["configSetName",CONFIG_SET_NAME],["voiceprintTag",VOICE_PRINT_TAG]]
        
        return connectToServer(url: url, params: params, method: "GET", notificationString: "ENROLL_SEGMENT_STATUS")
        
    }
    
    func deleteSpeaker(sessionId: String, speakerId: String) -> String {
        
        let url: String = "/vocalpassword/vocalpasswordserver.asmx/DeleteSpeaker"
        let params: [[String]] = [["sessionId","0"],["speakerId",speakerId],["configSetName",CONFIG_SET_NAME]]
        
        return connectToServer(url: url, params: params, method: "GET", notificationString: "DELETE_SPEAKER")
        
    }
    
    func addSpeakerToGroup(groupId: String) -> String {
        
        let url: String = "/vocalpassword/vocalpasswordserver.asmx/AddSpeakerToGroup"
        let params: [[String]] = [["sessionId","0"],["groupId",groupId],["configSetName",CONFIG_SET_NAME]]
        
        return connectToServer(url: url, params: params, method: "GET", notificationString: "ADD_SPEAKER")
        
    }
    
    func getGroupMembers(groupId: String) -> String {
        
        let url: String = "/vocalpassword/vocalpasswordserver.asmx/GetGroupMembers"
        let params: [[String]] = [["sessionId","0"],["groupId",groupId],["configSetName",CONFIG_SET_NAME]]
        
        return connectToServer(url: url, params: params, method: "GET", notificationString: "GROUP_MEMBERS")
        
    }
    
    func identify(groupId: String, audio: String) -> String {
        
        let url: String = "/VocalPassword/VocalPasswordServer.asmx/Identify"
        let params: [[String]] = [["sessionId","0"],["groupId",groupId],["configSetName",CONFIG_SET_NAME],["voiceprintTag",VOICE_PRINT_TAG],["text","null"],["audio",audio]]
        
        return connectToServer(url: url, params: params, method: "POST", notificationString: "IDENTIFY")
        
    }
    
}
