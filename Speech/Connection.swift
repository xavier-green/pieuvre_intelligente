//
//  Connection.swift
//  Speech
//
//  Created by xavier green on 17/03/2017.
//  Copyright © 2017 Google. All rights reserved.
//

import Foundation

class Connection {
    
    init() {
        print("Initialising back server connection")
    }
    
    private let BASE_URL: String = "https://westus.api.cognitive.microsoft.com/text/analytics/v2.0"
    private let KEY: String = "f11f53c893c64f1091a30588343e0e7d"
    
    private var resultData: String = ""
    
    func parseJson(jsonString: String) -> [String:Any]  {
        let data: Data = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        let dictionary = json as! [String:Any]
        return dictionary
    }
    
    func postRequest(connectionUrl: String, sendData: NSData, notificationString: String) -> String {
        
        print("Connecting to ",connectionUrl)
        
        //print(postParams)
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Ocp-Apim-Subscription-Key" : KEY]
        let session = URLSession(configuration: config)
        let url = URL(string: connectionUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = sendData as Data
        
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
                print(errors ?? "No errors")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ERROR"), object: errors)
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
    
    func sentiment(sentence: String) -> Double {
        
        print("Adding user to back")
        
        let url: String = "/sentiment"
        
        let timeInterval = String(NSDate().timeIntervalSince1970)
        
        let json = [
            "documents": [[
                "language": "fr",
                "id": timeInterval,
                "text": sentence
            ]]
        ]
        let jsonData: NSData
        do {
            jsonData = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions()) as NSData
//            print("data to send:")
//            print(NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)!)
            let sentimentObject = postRequest(connectionUrl: BASE_URL+url, sendData: jsonData, notificationString: "GET_SENTIMENT")
            let sentimentParsed = parseJson(jsonString: sentimentObject)
            let documentsArray = sentimentParsed["documents"] as! [[String: Any]]
            let scoreJSON = documentsArray[0] 
            let score = scoreJSON["score"] as! Double
            return score
            
        } catch _ {
            print ("JSON Failure")
            return -1
        }
        
    }
    
    
}






