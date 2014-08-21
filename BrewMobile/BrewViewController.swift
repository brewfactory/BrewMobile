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

class BrewCell: UITableViewCell {
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    func setTextColorForAllLabels(color: UIColor) {
        minLabel.textColor = color;
        statusLabel.textColor = color;
    }
}

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
                //println("Brew data: \(data)")
                
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
    
    func stateText(brewPhase: BrewPhase) -> String {
        if self.actState.paused {
            return "paused"
        }
        switch brewPhase.state  {
        case State.FINISHED:
            return "\(brewPhase.state.stateDescription()) at \(brewPhase.jobEnd)"
        case State.HEATING:
            if self.actTemp > brewPhase.temp { return "cooling" }
            fallthrough
        default:
            return brewPhase.state.stateDescription()
        }
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.actState.phases.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("BrewCell", forIndexPath: indexPath) as BrewCell
        if self.actState.phases.count > indexPath.row  {
            let brewPhase = self.actState.phases[indexPath.row]
        
            println(cell)
            cell.minLabel.text = "\(brewPhase.min) minutes at \(Int(brewPhase.temp)) ˚C"
            cell.statusLabel.text = "\(stateText(brewPhase))"
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                cell.backgroundColor = brewPhase.state.bgColor()
                cell.setTextColorForAllLabels(brewPhase.state == State.INACTIVE ? UIColor.blackColor() : UIColor.whiteColor())
            })
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}