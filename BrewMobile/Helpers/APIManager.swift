//
//  APIManager.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi-Nagy on 16/11/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation

class APIManager {
    class func createBrew(brew: BrewState) {
        if let brewJSON: JSON? = BrewState.encode(brew) {
            postRequestWithBody(brewJSON!)
        }
    }
    
    class func stopBrew() {
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: host + "api/brew/stop")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "PATCH"
        sendRequest(request)
    }
    
    class func postRequestWithBody(body: JSON) {
        var request : NSMutableURLRequest = NSMutableURLRequest()
        var serializationError: NSError?

        request.URL = NSURL(string: host + "api/brew")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions.PrettyPrinted, error: &serializationError)

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
