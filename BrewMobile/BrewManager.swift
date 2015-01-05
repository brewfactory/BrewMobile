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

class BrewManager : NSObject {
    
    let stopBrewSignal: RACSignal!
    let syncBrewCommand: RACCommand!

    override init() {
        super.init()

        syncBrewCommand = RACCommand(signalBlock: { (brewObject: AnyObject!) -> RACSignal! in
            return self.composeRequestSignalFromURLRequest(self.requestWithBody("api/brew", method: "POST", body: brewObject).value()!)
        })
        
        stopBrewSignal = composeRequestSignalFromURLRequest(self.requestWithBody("api/brew/stop", method: "PATCH", body: "").value()!)
    }

    private func requestWithBody(path: String, method: String, body: AnyObject) -> Result<NSMutableURLRequest> {
        var request : NSMutableURLRequest = NSMutableURLRequest()
        var serializationError: NSError?
        
        request.URL = NSURL(string: host + path)
        request.HTTPMethod = method
        if method == "POST" {
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted, error: &serializationError)
        }
        
        return (serializationError == nil ? success(request) : failure(serializationError!))
    }
    
    private func composeRequestSignalFromURLRequest(request: NSMutableURLRequest) -> RACSignal {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            
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
    
}