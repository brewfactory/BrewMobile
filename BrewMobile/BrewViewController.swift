//
//  ViewController.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 19/08/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import UIKit

class BrewViewController: UIViewController {
    let host = "http://brewcore-demo.herokuapp.com/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SIOSocket.socketWithHost(self.host, response: {socket in
            socket.onConnect = {
                println("connected to \(self.host)")
            }
            
            socket.onDisconnect = {
                println("disconnected from \(self.host)")
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}