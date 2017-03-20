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

class ConnectiontoBackServerMicrosoft {
    
    init() {
        print("Initialising back server connection")
    }
    /**
     SERVER INFORMATION
     **/
    private let BASE_URL: String = "http://localhost:3000/api"
    private let SERVER_USERNAME: String = "Youyoun"
    private let SERVER_PASSWORD: String = "password"
    
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
                print(errors!)
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
    func createUser(speakerId: String) -> String {
        
        let url: String = "/users"
        let params: [[String]] = [["username",speakerId]]
        
        return connectToServer(url: url, params: params, method: "POST", notificationString: "CREATED_USER")
        
    }
    
    func enroll(speakerId:String, fileUrl: URL) {
        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache",
        ]
        let fileData = try! NSData(contentsOf: fileUrl, options: NSData.ReadingOptions.mappedIfSafe)
        let base64String = fileData.base64EncodedString(options: [])
        print(base64String)
        let parameters = ["audio": "\(base64String)"] as [String : Any]
        
        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://localhost:3000/api/users/\(speakerId)/upload")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
            }
        })
        
        dataTask.resume()
    }
}






