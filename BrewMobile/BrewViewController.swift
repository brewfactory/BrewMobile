//
//  ViewController.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 19/08/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import UIKit

class BrewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let host = "http://brewcore-demo.herokuapp.com/"
    var actState :BrewState
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var phasesTableView: UITableView!

    required init(coder aDecoder: NSCoder) {
        actState = BrewState()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SIOSocket.socketWithHost(self.host, response: {socket in
            socket.onConnect = {
                println("connected to \(self.host)")
            }
            
            socket.onDisconnect = {
                println("disconnected from \(self.host)")
            }
            
            socket.on("temperature_changed", callback: {(AnyObject data) -> Void in
                let temp = data as Int
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.updateTempLabel(temp);
                    })
                })
            
            socket.on("brew_changed", callback: {(AnyObject data) -> Void in
                println("brew data: \(data)")
                
                self.actState = parseBrewState(data)!
               
                dispatch_async(dispatch_get_main_queue(), {
                    self.updateNameLabel();
                    self.updateStartTimeLabel()
                    })
                })
            })
    }
    
    func updateNameLabel() {
        self.nameLabel.text = "Brewing \(self.actState.name) at"
    }
    
    func updateTempLabel(temperature: Int) {
        self.tempLabel.text = "\(temperature) ˚C"
    }
    
    func updateStartTimeLabel() {
        self.startTimeLabel.text = "started \(self.actState.startTime)"
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "MyTestCell")
        
        //cell.textLabel.text = "\(indexPath.row)"
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}