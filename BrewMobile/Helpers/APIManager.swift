//
//  APIManager.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi-Nagy on 16/11/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation

class APIManager {
    
    //Mark: POST to /brew
    
    class func createBrew(brew: BrewState) {
        if let brewJSON: JSON? = BrewState.encode(brew) {
            requestWithBody("api/brew", method: "POST", body: brewJSON!)
        }
    }
    
    //Mark: PATCH to /brew/stop

    class func stopBrew() {
        requestWithBody("api/brew/stop", method: "PATCH", body: nil)
    }
    
    class func requestWithBody(path: String, method: String, body: JSON?) {
        var request : NSMutableURLRequest = NSMutableURLRequest()
        var serializationError: NSError?

        request.URL = NSURL(string: PersistentStorage.sharedInstance.host + path)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = method
        if body != nil {
             request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body!, options: NSJSONWritingOptions.PrettyPrinted, error: &serializationError)
        }
        
        if serializationError == nil {
            sendRequest(request)
        } else {
            println("Error serializing JSON from brew")
        }
    }
    
    class func sendRequest(request: NSMutableURLRequest) {
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: {
            (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            var serializationError: NSError?
            if error == nil {
                if data != nil {
                    if let jsonResult: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: &serializationError) {
                        if serializationError == nil {
                            println(jsonResult)
                        } else {
                            println("Error serializing JSON from brew")
                        }
                    }
                }
            } else {
                println("Error during request \(error.localizedDescription)")
            }
        })
    }

}
