//
//  SocketEngineSpec.swift
//  Socket.IO-Client-Swift
//
//  Created by Erik Little on 10/7/15.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

@objc public protocol SocketEngineSpec {
    weak var client: SocketEngineClient? { get set }
    var closed: Bool { get }
    var connected: Bool { get }
    var connectParams: [String: AnyObject]? { get set }
    var cookies: [NSHTTPCookie]? { get }
    var extraHeaders: [String: String]? { get }
    var fastUpgrade: Bool { get }
    var forcePolling: Bool { get }
    var forceWebsockets: Bool { get }
    var parseQueue: dispatch_queue_t! { get }
    var pingTimer: NSTimer? { get }
    var polling: Bool { get }
    var probing: Bool { get }
    var emitQueue: dispatch_queue_t! { get }
    var handleQueue: dispatch_queue_t! { get }
    var sid: String { get }
    var socketPath: String { get }
    var urlPolling: NSURL { get }
    var urlWebSocket: NSURL { get }
    var websocket: Bool { get }
    
    init(client: SocketEngineClient, url: NSURL, options: NSDictionary?)
    
    func close(reason: String)
    func didError(error: String)
    func doFastUpgrade()
    func flushWaitingForPostToWebSocket()
    func open()
    func parseEngineData(data: NSData)
    func parseEngineMessage(message: String, fromPolling: Bool)
    func write(msg: String, withType type: SocketEnginePacketType, withData data: [NSData])
}

extension SocketEngineSpec {
    var urlPollingWithSid: NSURL {
        let com = NSURLComponents(URL: urlPolling, resolvingAgainstBaseURL: false)!
        com.query = com.query! + "&sid=\(sid)"
        
        return com.URL!
    }
    
    var urlWebSocketWithSid: NSURL {
        let com = NSURLComponents(URL: urlWebSocket, resolvingAgainstBaseURL: false)!
        com.query = com.query! + (sid == "" ? "" : "&sid=\(sid)")
        
        return com.URL!
    }
    
    func createBinaryDataForSend(data: NSData) -> Either<NSData, String> {
        if websocket {
            var byteArray = [UInt8](count: 1, repeatedValue: 0x4)
            let mutData = NSMutableData(bytes: &byteArray, length: 1)
            
            mutData.appendData(data)
            
            return .Left(mutData)
        } else {
            let str = "b4" + data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            
            return .Right(str)
        }
    }
    
    /// Send an engine message (4)
    func send(msg: String, withData datas: [NSData]) {
        write(msg, withType: .Message, withData: datas)
    }
}
