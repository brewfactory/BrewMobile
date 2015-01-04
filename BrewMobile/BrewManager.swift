//
//  BrewManager.swift
//  BrewMobile
//
//  Created by Agnes Vasarhelyi on 03/01/15.
//  Copyright (c) 2015 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation
import SwiftyJSON
import ReactiveCocoa
import LlamaKit

class BrewManager {

    func requestWithBody(path: String, method: String, body: AnyObject) -> Result<NSMutableURLRequest> {
        var request : NSMutableURLRequest = NSMutableURLRequest()
        var serializationError: NSError?
        
        request.URL = NSURL(string: host + path)
        request.HTTPMethod = method
        if method == "POST" {
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted, error: &serializationError)
        }
        
        return (serializationError == nil ? success(request) : failure(serializationError!))
    }
    
    func sendRequest(request: NSMutableURLRequest) -> RACSignal {
        return RACSignal.createSignal({ (subscriber: RACSubscriber!) -> RACDisposable! in
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: {
                (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                if error == nil {
                    subscriber.sendNext(JSON(data).object)
                    subscriber.sendCompleted()
                } else {
                    subscriber.sendError(error)
                }
            })
            return RACDisposable()
        })
    }
 
    //MARK: POST to /brew
    
    func createBrew(brew: BrewState) {
        let brewJSON = BrewState.encode(brew)
        self.sendRequest(self.requestWithBody("api/brew", method: "POST", body: brewJSON.value()!).value()!)
    }
    
    //MARK: PATCH to /brew/stop
    
    func stopBrew() {
        self.sendRequest(self.requestWithBody("api/brew/stop", method: "PATCH", body: "").value()!)
    }
    
}