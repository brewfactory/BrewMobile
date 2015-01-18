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
import SocketIOFramework

class BrewManager : NSObject {
    let host = "http://localhost:3000/"
    let tempChangedEvent = "temperature_changed"
    let brewChangedEvent = "brew_changed"
    
    let stopBrewSignal: RACSignal!
    let syncBrewCommand: RACCommand!

    override init() {
        super.init()

        syncBrewCommand = RACCommand(signalBlock: { (brewObject: AnyObject!) -> RACSignal! in
            return self.composeRequestSignalFromURLRequest(self.requestWithBody("api/brew", method: "POST", body: brewObject).value()!).deliverOn(RACScheduler.mainThreadScheduler())
        })
        
        stopBrewSignal = composeRequestSignalFromURLRequest(self.requestWithBody("api/brew/stop", method: "PATCH", body: "").value()!).deliverOn(RACScheduler.mainThreadScheduler())
    }

    //Mark: HTTP
    
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
        let scheduler = RACScheduler(priority: RACSchedulerPriorityBackground)
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
        }).subscribeOn(scheduler)
    }
    
    // MARK: WebSocket
    
    func connectToHost() -> RACSignal {
        let scheduler = RACScheduler(priority: RACSchedulerPriorityBackground)
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            SIOSocket.socketWithHost(self.host, reconnectAutomatically: true, attemptLimit: 0, withDelay: 1, maximumDelay: 5, timeout: 20, response: {socket in
                socket.onConnect = {
                    println("Connected to \(self.host)")
                }
                
                socket.onDisconnect = {
                    println("Disconnected from \(self.host)")
                }
                
                socket.on(self.tempChangedEvent, callback: { (AnyObject data) -> Void in
                    subscriber.sendNext(["event": self.tempChangedEvent, "data": data])
                })
                
                socket.on(self.brewChangedEvent, callback: { (AnyObject data) -> Void in
                    subscriber.sendNext(["event": self.brewChangedEvent, "data": data])
                })
                
                socket.onError = { (AnyObject anyError) -> Void in
                    subscriber.sendError(NSError())
                }
            })
            return RACDisposable()
        }).subscribeOn(scheduler)
    }
}