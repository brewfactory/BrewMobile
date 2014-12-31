//
//  APIManager.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi-Nagy on 16/11/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation
import LlamaKit
import SwiftyJSON

class APIManager {
    
    //MARK: POST to /brew
    
    class func createBrew(brew: BrewState) {
        let brewJSON = BrewState.encode(brew)
        sendRequest(requestWithBody("api/brew", method: "POST", body: brewJSON.value()!).value()!)
    }
    
    //MARK: PATCH to /brew/stop

    class func stopBrew() {
        sendRequest(requestWithBody("api/brew/stop", method: "PATCH", body: "").value()!)
    }
    
    class func requestWithBody(path: String, method: String, body: AnyObject) -> Result<NSMutableURLRequest> {
        var request : NSMutableURLRequest = NSMutableURLRequest()
        var serializationError: NSError?

        request.URL = NSURL(string: host + path)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = method
        if method == "POST" {
             request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions.PrettyPrinted, error: &serializationError)
        }
        
        if serializationError == nil {
            return success(request)
        } else {
            return failure(serializationError!)
        }
    }
    
    class func sendRequest(request: NSMutableURLRequest) {
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: {
            (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            var serializationError: NSError?
            if error == nil {
                if data != nil {
                    let jsonResult = JSON(data)
                }
            } else {
                println("Error during request \(error.localizedDescription)")
            }
        })
    }

}
