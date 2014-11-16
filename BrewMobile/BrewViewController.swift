//
//  ViewController.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 19/08/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import UIKit

let host = "http://brewcore-demo.herokuapp.com/"

class BrewCell: UITableViewCell {
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    func setTextColorForAllLabels(color: UIColor) {
        minLabel.textColor = color
        statusLabel.textColor = color
    }
}

class BrewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var actState: BrewState
    var actTemp: Float
    
    let tempChangedEvent = "temperature_changed"
    let brewChangedEvent = "brew_changed"
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var phasesTableView: UITableView!
    
    required init(coder aDecoder: NSCoder) {
        actState = BrewState()
        actTemp = 0
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.connectToHost()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: SIOSocket
    
    private func connectToHost() {
        SIOSocket.socketWithHost(host, reconnectAutomatically: true, attemptLimit: 0, withDelay: 1, maximumDelay: 5, timeout: 20, response: {socket in
            socket.onConnect = {
                println("Connected to \(host)")
            }
            
            socket.onDisconnect = {
                println("Disconnected from \(host)")
            }
            
            socket.on(self.tempChangedEvent, callback: {(AnyObject data) -> Void in
                if data.count > 0 {
                    self.actTemp = data[0] as Float
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.updateTempLabel(self.actTemp)
                })
            })
            
            socket.on(self.brewChangedEvent, callback: {(AnyObject data) -> Void in
                if data.count > 0 {
                    self.actState = parseBrewState(data[0])!
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.phasesTableView.reloadData()
                        self.updateNameLabel()
                        self.updateStartTimeLabel()
                    })
                }
            })
        })
    }
    
    // MARK: refresh UI
    
    func updateNameLabel() {
        if self.actState.phases.count > 0 {
            self.nameLabel.text = "Brewing \(self.actState.name) at"
        } else {
            self.nameLabel.text = "We are not brewing :(\nHow is it possible?"
        }
    }
    
    func updateTempLabel(temperature: Float) {
        self.tempLabel.text = NSString(format:"%.2f ˚C", temperature)
    }
    
    func updateStartTimeLabel() {
        self.startTimeLabel.text = "starting \(self.actState.startTime)"
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
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.actState.phases.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BrewCell", forIndexPath: indexPath) as BrewCell
        if self.actState.phases.count > indexPath.row  {
            let brewPhase = self.actState.phases[indexPath.row]
            
            cell.minLabel.text = "\(brewPhase.min) minutes at \(Int(brewPhase.temp)) ˚C"
            cell.statusLabel.text = "\(self.stateText(brewPhase))"
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                cell.backgroundColor = brewPhase.state.bgColor()
                cell.setTextColorForAllLabels(brewPhase.state == State.INACTIVE ? UIColor.blackColor() : UIColor.whiteColor())
            })
        }
        
        return cell
    }
    
}
