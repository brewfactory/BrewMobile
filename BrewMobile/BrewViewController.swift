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
    
    func updateTempLabel(temperature: Int) {
        self.tempLabel.text = "\(temperature) ˚C"
    }
    
    func updateStartTimeLabel() {
        self.startTimeLabel.text = self.actState.inProgress ? "started \(self.actState.startTime)" : ""
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.actState.phases.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "BrewCell")
        cell.textLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        if self.actState.phases.count > indexPath.row  {
            let brewPhase = self.actState.phases[indexPath.row]
            cell.textLabel.text = "\(brewPhase.min) minutes at \(brewPhase.temp) ˚C"
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}