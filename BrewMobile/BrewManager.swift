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
import SocketIOClientSwift

let tempChangedEvent = "temperature_changed"
let brewChangedEvent = "brew_changed"
let pwmChangedEvent = "pwm_changed"
let host = "https://brewcore-demo.herokuapp.com/"

class BrewManager : NSObject {
    var syncBrewAction: Action<BrewState, NSData, NSError>!
    var stopBrewAction: Action<Void, NSData, NSError>!
    var socket: SocketIOClient
    let temp = MutableProperty<Float>(0.0)
    let brew = MutableProperty(BrewState())
    let pwm = MutableProperty<Float>(0.0)

    override init() {
        socket = SocketIOClient(socketURL:NSURL(string: host)!)

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
        let request : NSMutableURLRequest = NSMutableURLRequest()

        request.URL = NSURL(string: host + path)
        request.HTTPMethod = method
        if method == "POST" {
            do {
                request.HTTPBody = try body.rawData(options: .PrettyPrinted)
            } catch let error as NSError {
                return Result(error: error)
            }
        }
        
        return Result(request)
    }
    
    // MARK: WebSocket
    
    func connectToHost() {
        socket.connect()

        socket.on(tempChangedEvent) { data, ack in
            if (data.count > 0) {
                if let temp = data[0] as? NSNumber {
                    self.temp.value = temp.floatValue
                }
            }
        }
        
        socket.on(brewChangedEvent) { data, ack in
            if (data.count > 0) {
                self.brew.value = ContentParser.parseBrewState(JSON(data[0]))
            }
        }
        
        socket.on(pwmChangedEvent) { data, ack in
            if (data.count > 0) {
                if let pwm = data[0] as? NSNumber {
                    self.pwm.value = pwm.floatValue
                }
            }
        }
        
        socket.on("connect") { data, ack in
            print("Connected to \(host)")
        }

        socket.on("disconnect") { data, ack in
            print("Disconnected from \(host)")
        }

    }

}
