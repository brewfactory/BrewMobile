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
    
    var syncBrewAction: Action<BrewState, NSData, NSError>!
    var stopBrewAction: Action<Void, NSData, NSError>!
    let temp = MutableProperty<Float>(0.0)
    let brew = MutableProperty(BrewState())
    let pwm = MutableProperty<Float>(0.0)

    override init() {
         super.init()

        syncBrewAction = Action { brewState in
            if let jsonData:AnyObject = BrewState.encode(brewState).value {
                let requestResult = self.requestWithBody("api/brew", method: "POST", body: JSON(jsonData))
                if let requestResultValue = requestResult.value {
                    return NSURLSession.sharedSession().rac_dataWithRequest(requestResultValue)
                        .map { data, URLResponse in
                            return data
                        }
                }
            }
            fatalError("jsonData is nil")
        }

        stopBrewAction = Action { brewState in
            if let request = self.requestWithBody("api/brew/stop", method: "PATCH", body: "").value {
                return NSURLSession.sharedSession().rac_dataWithRequest(request)
                    .map { data, URLResponse in
                        return data
                    }
            }
            fatalError("request is nil")
        }
    }

    //Mark: HTTP
    
    private func requestWithBody(path: String, method: String, body: JSON) -> Result<NSMutableURLRequest, NSError> {
        var request : NSMutableURLRequest = NSMutableURLRequest()
        
        request.URL = NSURL(string: host + path)
        request.HTTPMethod = method
        if method == "POST" {
            request.HTTPBody = body.rawData(options: .PrettyPrinted, error: &serializationError)
            if let error = serializationError {
                return Result.failure(error)
            }
        }
        
        return Result.success(request)
    }
    
    // MARK: WebSocket
    
    func connectToHost() {
        SIOSocket.socketWithHost(self.host, reconnectAutomatically: true, attemptLimit: 0, withDelay: 1, maximumDelay: 5, timeout: 20, response: {socket in
            socket.onConnect = {
                print("Connected to \(self.host)")
            }
            
            socket.onDisconnect = {
                print("Disconnected from \(self.host)")
            }
            
            socket.on(tempChangedEvent, callback: { (AnyObject data) -> Void in
                if (count(data) > 0) {
                    if let temp = data[0] as? NSNumber {
                        self.temp(temp.floatValue)
                    }
                }
            })
            
            socket.on(brewChangedEvent, callback: { (AnyObject data) -> Void in
                if (count(data) > 0) {
                    self.brew(ContentParser.parseBrewState(JSON(data[0])))
                }
            })
            
            socket.on(pwmChangedEvent, callback: { (AnyObject data) -> Void in
                if (count(data) > 0) {
                    if let pwm = data[0] as? NSNumber {
                        self.pwm(pwm.floatValue)
                    }
                }
            })
            
            socket.onError = { (AnyObject anyError) -> Void in
                print("Socket connection error")
            }
        })
    }
