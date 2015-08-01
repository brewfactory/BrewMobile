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
import Result
import SocketIOFramework

let tempChangedEvent = "temperature_changed"
let brewChangedEvent = "brew_changed"
let pwmChangedEvent = "pwm_changed"

class BrewManager : NSObject {
    let host = "http://brewcore-demo.herokuapp.com/"
    
    var stopBrewCommand: RACCommand!
    var syncBrewAction: Action<BrewState, Void, NSError>!
    let tempChangedSignal: RACSubject
    let brewChangedSignal: RACSubject
    let pwmChangedSignal: RACSubject
    
    var syncRequest: RACSignal!

    override init() {
        tempChangedSignal = RACSubject()
        brewChangedSignal = RACSubject()
        pwmChangedSignal = RACSubject()
        
        super.init()

        syncBrewAction = Action<BrewState, Void, NSError>(enabledIf: MutableProperty(true), { brewState in
            let requestResult = self.requestWithBody("api/brew", method: "POST", body: JSON(BrewState.encode(brewState).value!))
            return NSURLSession.sharedSession().rac_dataWithRequest(requestResult.value!)
                |> map { data, URLResponse in
                    return ""
                }
        })

        stopBrewCommand = RACCommand(signalBlock: { Void -> RACSignal! in
            let request = self.requestWithBody("api/brew/stop", method: "PATCH", body: "").value!
            return NSURLConnection.rac_sendAsynchronousRequest(request)
        })
    }

    //Mark: HTTP
    
    private func requestWithBody(path: String, method: String, body: JSON) -> Result<NSMutableURLRequest, NSError> {
        var request : NSMutableURLRequest = NSMutableURLRequest()
        var serializationError: NSError?
        
        request.URL = NSURL(string: host + path)
        request.HTTPMethod = method
        if method == "POST" {
            request.HTTPBody = body.rawData(options: .PrettyPrinted, error: &serializationError)
            if serializationError != nil {
                return Result.failure(serializationError!)
            }
        }
        
        return Result.success(request)
    }
    
    // MARK: WebSocket
    
    func connectToHost() {
        SIOSocket.socketWithHost(self.host, reconnectAutomatically: true, attemptLimit: 0, withDelay: 1, maximumDelay: 5, timeout: 20, response: {socket in
            socket.onConnect = {
                println("Connected to \(self.host)")
            }
            
            socket.onDisconnect = {
                println("Disconnected from \(self.host)")
            }
            
            socket.on(tempChangedEvent, callback: { (AnyObject data) -> Void in
                if(count(data) > 0) {
                    let temp = data[0] as! NSNumber
                    self.tempChangedSignal.sendNext(temp)
                }
            })
            
            socket.on(brewChangedEvent, callback: { (AnyObject data) -> Void in
                if(count(data) > 0) {
                    self.brewChangedSignal.sendNext([brewChangedEvent: ContentParser.parseBrewState(JSON(data[0]))])
                }
            })
            
            socket.on(pwmChangedEvent, callback: { (AnyObject data) -> Void in
                if(count(data) > 0) {
                    let pwm = data[0] as! NSNumber
                    self.pwmChangedSignal.sendNext(pwm)
                }
            })
            
            socket.onError = { (AnyObject anyError) -> Void in
                println("Socket connection error")
            }
        })
    }
    
}
