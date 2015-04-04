//
//  ViewController.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 19/08/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import UIKit
import SwiftyJSON
import ReactiveCocoa

class BrewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let brewViewModel: BrewViewModel

    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var pwmLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var phasesTableView: UITableView!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    
    init(brewViewModel: BrewViewModel) {
        self.brewViewModel = brewViewModel
        super.init(nibName:"BrewViewController", bundle: nil)
        self.tabBarItem = UITabBarItem(title: "Brew", image: UIImage(named: "HopIcon"), tag: 0)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopButton.rac_command = RACCommand() {
            (any:AnyObject!) -> RACSignal in
            let stopSignal = self.brewViewModel.stopCommand.execute(nil)
            stopSignal.subscribeError({ (error: NSError!) -> Void in
                UIAlertView(title: "Error stopping brew", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
            })
            return stopSignal
        }
        
        let nib = UINib(nibName: "BrewCell", bundle: nil)
        phasesTableView.registerNib(nib, forCellReuseIdentifier: "BrewCell")

        self.brewViewModel.tempChangedSignal.map {
            (temp: AnyObject!) -> AnyObject! in
            return NSString(format:"%.2f ˚C", temp.floatValue as Float)
        } ~> RAC(self.tempLabel, "text")
        
        self.brewViewModel.pwmChangedSignal.map {
            (pwm: AnyObject!) -> AnyObject! in
            return "PWM: \(pwm.intValue as Int32) %"
        } ~> RAC(self.pwmLabel, "text")
        
        self.brewViewModel.brewChangedSignal.subscribeNext {
            (next: AnyObject!) -> Void in
            self.phasesTableView.reloadData()
            
            if self.brewViewModel.state.phases.count > 0 {
                self.nameLabel.text = "Brewing \(self.brewViewModel.state.name) at"
            } else {
                self.nameLabel.text = "We are not brewing :(\nHow is it possible?"
            }
            
            self.startTimeLabel.text = self.brewViewModel.state.phases.count > 0 ? "starting \(self.brewViewModel.state.startTime)" : ""
        }
    }
    
    func stateText(brewPhase: BrewPhase) -> String {
        if self.brewViewModel.state.paused {
            return "paused"
        }
        switch brewPhase.state  {
        case State.FINISHED:
            return "\(brewPhase.state.stateDescription()) at \(brewPhase.jobEnd)"
        case State.HEATING:
            if self.brewViewModel.temp > brewPhase.temp { return "cooling" }
            fallthrough
        default:
            return brewPhase.state.stateDescription()
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.brewViewModel.state.phases.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BrewCell", forIndexPath: indexPath) as BrewCell
        if self.brewViewModel.state.phases.count > indexPath.row  {
            let brewPhase = self.brewViewModel.state.phases[indexPath.row]
            
            cell.minLabel.text = brewPhase.jobEnd != "" ? "\(brewPhase.min) mins - \(Int(brewPhase.temp)) ˚C, ends: \(brewPhase.jobEnd)"  : "\(brewPhase.min) mins - \(Int(brewPhase.temp)) ˚C"
            cell.statusLabel.text = "\(self.stateText(brewPhase))"
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                cell.backgroundColor = brewPhase.state.bgColor()
                cell.setTextColorForAllLabels(brewPhase.state == State.INACTIVE ? UIColor.blackColor() : UIColor.whiteColor())
            })
        }
        
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
