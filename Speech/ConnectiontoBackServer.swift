//
//  ServerConnection.swift
//  Capgemini
//
//  Created by younes belkouchi on 27/02/2017.
//  Copyright © 2017 xavier green. All rights reserved.
//
//  This Module Defines the functions that send requests to the server.
//  They are later used in CotoBackMethods.swift
//

import Foundation
import UIKit

class ConnectiontoBackServer {
    
    init() {
        print("Initialising back server connection")
    }
    /**
     SERVER INFORMATION
     **/
    private let BASE_URL: String = Config.serverURL
    private let SERVER_USERNAME: String = Config.serverUsername
    private let SERVER_PASSWORD: String = Config.serverPassword
    
    private var resultData: String = ""
    
    //MARK: Request Functions
    
    func connectToServer(url: String, params: [[String]], method: String, notificationString: String) -> String {
        
        if method=="GET" {
            
            let connectionUrl = constructURL(base: BASE_URL, url: url, params: params)
            return getRequest(connectionUrl: connectionUrl, notificationString: notificationString)
            
        } else if method=="POST" {
            
            return postRequest(connectionUrl: BASE_URL+url, params: params, notificationString: notificationString)
            
        } else if method=="PUT" {
            
            let connectionUrl = constructURL(base: BASE_URL, url: url, params: params)
            return putRequest(connectionUrl: connectionUrl, notificationString: notificationString)
            
        }
        
        return ""
        
    }
    
    func putRequest(connectionUrl: String, notificationString: String) -> String {
        
        print("Connecting to ",connectionUrl)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest=TimeInterval(20)
        config.timeoutIntervalForResource=TimeInterval(60)
        let authString = constructHeaders()
        config.httpAdditionalHeaders = ["Authorization" : authString]
        let session = URLSession(configuration: config)
        let url = URL(string: connectionUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        return sendRequest(session: session, request: request, notificationString: notificationString)
        
    }
    
    func getRequest(connectionUrl: String, notificationString: String) -> String {
        
        print("Connecting to ",connectionUrl)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest=TimeInterval(20)
        config.timeoutIntervalForResource=TimeInterval(60)
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
        let sendData = postParams.data(using: String.Encoding.utf8)!
        
        //print(postParams)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest=TimeInterval(20)
        config.timeoutIntervalForResource=TimeInterval(60)
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
                NotificationCenter.default.post(name: Notification.Name(rawValue: "TIME_OUT_BACK"), object: errors)
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                //print("response = \(response)")
                print("******** REQUEST ERROR")
                errors = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as? String
                
                // In case of error, send notification observed from App Delegate
                // Shows pop up the says an error happened
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ERROR_BACK"), object: errors)
                return
                
            }
            dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as? String
            //print(dataString)
            
            semaphore.signal()
            
            print("Done, sending notification: ",notificationString)
            
            //            NotificationCenter.default.post(name: Notification.Name(rawValue: notificationString), object: dataString)
            
        }).resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        if let error = errors {
            print(error)
        }
        
        return dataString!
        
    }
    
    //MARK: Set Headers for request
    
    func constructHeaders() -> String {
        
        let loginString = String(format: "%@:%@", SERVER_USERNAME, SERVER_PASSWORD)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        let authString = "Basic \(base64LoginString)"
        //print("authstring: ",authString)
        return authString
        
    }
    
    func constructURL(base: String, url: String, params: [[String]]) -> String {
        if params[0]==[] {
            let finalUrl = base + url
            return finalUrl
        } else {
            var finalUrl = base + url + "?"
            for param in params {
                finalUrl += param[0]+"="+param[1]+"&"
            }
            return finalUrl
        }
    }
    
    //MARK: Set Parameters for request
    
    func constructParams(params: [[String]]) -> String {
        
        var finalUrl = ""
        print("params length: ",params.count)
        if (params.count > 0) {
            for param in params {
                //print("param: ",param)
                finalUrl += param[0]+"="+param[1]+"&"
            }
        }
        return finalUrl
        
    }
    
    //MARK: Request Functions used in App
    
    
    /**
     Gets all Users Json
     Contains All Attributes for each user
     - Parameters: None
     - Returns: Users Json
     */
    func getUserList() -> String {
        
        let url: String = "/users"
        let params: [[String]] = [[]]
        
        return connectToServer(url: url, params: params, method: "GET", notificationString: "GET_USERS")
        
    }
    
    /**
     Gets all Users Json
     Contains All Attributes for each user
     - Parameters: None
     - Returns: Users Json
     
     This function is parsed differently
     */
    func getUsersNames() -> String {
        let url: String = "/users"
        let params: [[String]] = [[]]
        
        return connectToServer(url: url, params: params, method: "GET", notificationString: "GET_USERS_NAMES")
    }
    
    func getTopUsersName(position: Int) -> String {
        let url: String = "/users/getfirst"
        let params: [[String]] = [["position", String(position)]]
        
        return connectToServer(url: url, params: params, method: "POST", notificationString: "GET_USERS_NAMES")
    }
    
    
    /**
     Add User To database in Enrolment Phase
     Post request containing request data
     - Parameters:
     - speakerID : String containing the name chosen by the user
     - memDate : Memorable Date chosen by user
     - Returns: JSON of the new added user
     */
    func addUser(speakerId: String, memDate: String) -> String {
        
        print("Adding user to back")
        
        let url: String = "/users"
        let params: [[String]] = [["username",speakerId],["memDate",memDate]]
        
        return connectToServer(url: url, params: params, method: "POST", notificationString: "ADD_USER")
        
    }
    
    
    /**
     Verify User's Date in Authentication
     Post request containing request data
     - Parameters:
     - speakerID : String containing the name chosen by the user
     - memDate : Memorable Date chosen by user
     - Returns: Json containing speakerId and authorised attributes. Authorized is true when user has entered correct date.
     */
    func verifyUser(speakerId: String, memDate: String) -> String {
        print("Verifying user date")
        
        let url: String = "/users/verifyDate"
        let params: [[String]] = [["username",speakerId],["memDate",memDate]]
        
        return connectToServer(url: url, params: params, method: "POST", notificationString: "VERIFY_USER")
    }
    
    /**
     Get One user by Name
     - Parameter SpeakerId: User name
     - Returns: Json containing speakerId's Information
     */
    func getUser(speakerId: String) -> String {
        print("Getting user attribute")
        
        let url: String = "/users/\(speakerId)"
        let params: [[String]] = [[]]
        
        return connectToServer(url: url, params: params, method: "GET", notificationString: "GET_USER")
    }
    
    /**
     Add Image in base64 to the database in App Storyboard
     - Parameters:
     - username : String containing the name chosen by the user
     - base64Image : Image Drawn encoded in base64
     */
    func addImage(base64image: String, username: String) -> String {
        
        print("saving image to server")
        let url: String = "/images"
        let params: [[String]] = [["imageData",base64image],["username",username]]
        
        return connectToServer(url: url, params: params, method: "POST", notificationString: "POST_IMAGE")
        
    }
    
    /**
     
     Add Images in base64 from the database in App Storyboard
     
     */
    func getImages() -> String {
        
        print("getting images from db")
        let url: String = "/images"
        let params: [[String]] = [["username",GlobalVariables.username]]
        
        return connectToServer(url: url, params: params, method: "GET", notificationString: "GET_IMAGES")
        
    }
    
    func getTopImage(position: Int) -> String {
        
        print("getting images from db")
        let url: String = "/images/topimage"
        let params: [[String]] = [["username",GlobalVariables.username],["position",String(position)]]
        
        return connectToServer(url: url, params: params, method: "POST", notificationString: "GET_IMAGES")
        
    }
    
    /**
     Vote for an image from all the images
     Increments the vote attribute of image in database
     - Parameter imageId: ImageId in the database
     */
    func voteForImage(imageId: Int) -> String {
        
        print("voting for ",imageId)
        let url: String = "/images/"+String(imageId)
        let params: [[String]] = [[]]
        
        return connectToServer(url: url, params: params, method: "PUT", notificationString: "VOTE_DONE")
        
    }
    
    /**
     Get images classed by votes
     */
    func getLeaderboard() -> String {
        
        print("getting leaderboard")
        let url: String = "/images/leader"
        let params: [[String]] = [[]]
        
        return connectToServer(url: url, params: params, method: "GET", notificationString: "LEADER_DONE")
        
    }
    
    func getTopLeaderboard(position: Int) -> String {
        
        print("getting leaderboard")
        let url: String = "/images/getfirst"
        let params: [[String]] = [["position",String(position)]]
        
        return connectToServer(url: url, params: params, method: "POST", notificationString: "LEADER_DONE")
        
    }
    
    /**
     Get User frequency
     - Parameter speakerId: name chosen by user
     - Returns: Json containing Registered that is true when user has registered his frequency. Json also contains said frequency.
     */
    func getFrequency(speakerId: String) -> String {
        print("Getting user frequency")
        
        let url: String = "/users/addFrequency"
        let params: [[String]] = [["username","\(speakerId)"]]
        
        return connectToServer(url: url, params: params, method: "POST", notificationString: "GET_USER_FREQ")
    }
    
    /**
     Add User frequency
     - Parameters:
     - speakerId: name chosen by user
     - frequency: frequency of the user
     - Returns: Json containing Registered=true. Json also contains set frequency.
     */
    func addFrequency(speakerId:String, frequency: Any) -> String {
        print("Sending user frequency")
        
        let url: String = "/users/addFrequency"
        let params: [[String]] = [["username","\(speakerId)"],["frequency","\(frequency)"]]
        
        return connectToServer(url: url, params: params, method: "POST", notificationString: "SEND_USER_FREQ")
    }
    
    
    //MARK: Stats
    
    /**
     Add Hack success to database
     Hacker And Hacked Must be Entered
     - Parameters:
     - hacker : String containing the name of the hacker
     - hacked : String containing the name of the hacked
     */
    func addHack(hacker: String, hacked: String) -> String {
        
        print("hacking of ",hacked," by ",hacker)
        let url: String = "/stats/addHack"
        let params: [[String]] = [["hacked",hacked],["hacker",hacker]]
        
        return connectToServer(url: url, params: params, method: "POST", notificationString: "ADD_HACK_DONE")
        
    }
    
    /**
     Increment hackAttempt in Database
     Post request to url
     */
    func hackAttempt() -> String {
        
        print("Prevented hack !")
        let url: String = "/stats/hackAttempt"
        let params = [[String]]()
        
        return connectToServer(url: url, params: params, method: "POST", notificationString: "HACK_ATTEMPT_DONE")
        
    }
    
    /**
     Increment LoginSuccess in Database
     Post request to url
     */
    func loginSuccess() -> String {
        
        print("Login success !")
        let url: String = "/stats/loginSuccess"
        let params = [[String]]()
        
        return connectToServer(url: url, params: params, method: "POST", notificationString: "LOGIN_SUCCESS_DONE")
        
    }
    
    /**
     Increment LoginFail in Database
     Post request to url
     */
    func loginFail(email: String, username: String) -> String {
        
        print("Login failed ! Reponse to: ",email)
        let url: String = "/stats/loginFail"
        let params: [[String]] = [["email",email],["username",username]]
        
        return connectToServer(url: url, params: params, method: "POST", notificationString: "LOGIN_FAIL_DONE")
        
    }
    
    /**
     Increment hackAttempt in Database
     Post request to url
     */
    func loggingAttempt() -> String {
        print("Adding login attempt")
        let url: String = "/stats/loginAttempt"
        let params: [[String]] = []
        
        return connectToServer(url: url, params: params, method: "POST", notificationString: "ADD_LOG")
    }
    
    /**
     Increment hackAttempt in Database
     Post request to url
     */
    func enrolAttempt() -> String {
        print("Adding Enrol Attempt")
        
        let url: String = "/stats/enrolAttempt"
        let params: [[String]] = []
        
        return connectToServer(url: url, params: params, method: "POST", notificationString: "ADD_ENR")
    }
    
    
}






