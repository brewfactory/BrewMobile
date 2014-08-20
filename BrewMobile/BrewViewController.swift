//
//  ViewController.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 19/08/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import UIKit

let tempChangedEvent = "temperature_changed"
let brewChangedEvent = "brew_changed"
let host = "http://brewcore-demo.herokuapp.com/"

class BrewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var actState: BrewState
    var actTemp: Float
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var phasesTableView: UITableView!

    required init(coder aDecoder: NSCoder) {
        actState = BrewState()
        actTemp = 0;
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SIOSocket.socketWithHost(host, response: {socket in
            socket.onConnect = {
                println("Connected to \(host)")
            }
            
            socket.onDisconnect = {
                println("Disconnected from \(host)")
            }
            
            socket.on(tempChangedEvent, callback: {(AnyObject data) -> Void in
                self.actTemp = data as Float
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.updateTempLabel(self.actTemp);
                    })
                })
            
            socket.on(brewChangedEvent, callback: {(AnyObject data) -> Void in
                println("Brew data: \(data)")
                
                self.actState = parseBrewState(data)!
               
                dispatch_async(dispatch_get_main_queue(), {
                    self.phasesTableView.reloadData()
                    self.updateNameLabel();
                    self.updateStartTimeLabel()
                })
            })
        })
    }
    
    func updateNameLabel() {
        self.nameLabel.text = self.actState.inProgress ? "Brewing \(self.actState.name) at" : ""
    }
    
    func updateTempLabel(temperature: Float) {
        self.tempLabel.text = NSString(format:"%.2f ˚C", temperature)
    }
    
    func updateStartTimeLabel() {
        self.startTimeLabel.text = self.actState.inProgress ? "started at \(self.actState.startTime)" : ""
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.actState.phases.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "BrewCell")
        cell.textLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        
        if self.actState.phases.count > indexPath.row  {
            let brewPhase = self.actState.phases[indexPath.row]
            let stateText = {() -> String in if (brewPhase.state == State.HEATING) && (Int(self.actTemp) > brewPhase.temp) { return "cooling" } else { return brewPhase.state.stateDescription() }}()
           
            cell.textLabel.text = "\(brewPhase.min) minutes at \(brewPhase.temp) ˚C \t \(stateText)"
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}