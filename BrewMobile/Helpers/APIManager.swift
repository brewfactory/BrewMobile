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
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: host + "api/brew")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        
        var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
        
        if let brewJSON: JSON? = BrewState.encode(brew) {
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(brewJSON!, options: NSJSONWritingOptions.PrettyPrinted, error: error)
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                
                let jsonResult: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: nil)!
                
                println(jsonResult)
            })
        }
        
    }
    
}
