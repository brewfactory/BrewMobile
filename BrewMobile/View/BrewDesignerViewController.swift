//
//  BrewDesignerViewController.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 07/11/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import UIKit
import ISO8601
import ReactiveCocoa

class BrewDesignerViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var phasesTableView: UITableView!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var pickerBgView: UIView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var syncButton: UIBarButtonItem!
    @IBOutlet weak var cloneButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!

    let brewDesignerViewModel: BrewDesignerViewModel
    
    init(brewDesignerViewModel: BrewDesignerViewModel) {
        self.brewDesignerViewModel = brewDesignerViewModel
        super.init(nibName:"BrewDesignerViewController", bundle: nil)
        self.tabBarItem = UITabBarItem(title: "Designer", image: UIImage(named: "DesignerIcon"), tag: 0)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem()
        self.navigationItem.leftBarButtonItem?.title = "Sync"
        syncButton = self.navigationItem.leftBarButtonItem

        self.navigationItem.rightBarButtonItem = UIBarButtonItem()
        self.navigationItem.rightBarButtonItem?.title = "Edit"
        editButton = self.navigationItem.rightBarButtonItem

        let nib = UINib(nibName: "PhaseCell", bundle: nil)
        phasesTableView.registerNib(nib, forCellReuseIdentifier: "PhaseCell")
        
        editButton.rac_command = RACCommand(enabled: self.brewDesignerViewModel.hasPhasesSignal) {
            (any:AnyObject!) -> RACSignal in
            self.phasesTableView.editing = !self.phasesTableView.editing
            return RACSignal.empty()
        }

        syncButton.rac_command = RACCommand(enabled: self.brewDesignerViewModel.validBeerSignal) {
            (any:AnyObject!) -> RACSignal in
            let syncSignal = self.brewDesignerViewModel.syncCommand.execute(nil)
            syncSignal.subscribeError({ (error: NSError!) -> Void in
                UIAlertView(title: "Error creating brew", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
            })
            return syncSignal
        }
        
        trashButton.rac_command = RACCommand() {
            (any:AnyObject!) -> RACSignal in
            self.brewDesignerViewModel.phases = PhaseArray()
            self.nameTextField.text = ""
            self.phasesTableView.reloadData()
            return RACSignal.empty()
        }
        
        addButton.rac_command = RACCommand() {
            (any:AnyObject!) -> RACSignal in
            self.navigationController?.pushViewController(BrewNewPhaseViewController(brewDesignerViewModel: self.brewDesignerViewModel), animated: true)
            return RACSignal.empty()
        }

        self.brewDesignerViewModel.hasPhasesSignal.subscribeNext {
            (next: AnyObject!) -> () in

            if !self.phasesTableView.editing {
                self.phasesTableView.reloadData()
            }

            if !(next as Bool) {
                self.phasesTableView.editing = false
            }
        }

        RACObserve(self.phasesTableView, "editing").subscribeNext {
            (editing: AnyObject!) -> Void in
            let editingValue = editing as Bool
            self.editButton.title = editingValue ? "Done" : "Edit"
        }
        
        self.nameTextField.rac_textSignal() ~> RAC(self.brewDesignerViewModel, "name")
        self.startTimeTextField.rac_textSignal() ~> RAC(self.brewDesignerViewModel, "startTime")
        
        let statTimeTextFieldPressed = self.startTimeTextField.rac_signalForControlEvents(.EditingDidBegin)
        statTimeTextFieldPressed.subscribeNext(dismissKeyboard)
        statTimeTextFieldPressed.mapReplace(false) ~> RAC(self.pickerBgView, "hidden")

        self.brewDesignerViewModel.syncCommand.executionSignals.subscribeNext(dismissKeyboard)
        editButton.rac_command.executionSignals.subscribeNext(dismissKeyboard)
        
        let startTimeValueChangedSignal = RACObserve(self.startTimePicker, "date").startWith(NSDate())

        startTimeValueChangedSignal.map {
            (pickerDate: AnyObject!) -> AnyObject! in
            let date = pickerDate as NSDate
            
            let isoDateFormatter = ISO8601DateFormatter()
            isoDateFormatter.defaultTimeZone = NSTimeZone.defaultTimeZone()
            isoDateFormatter.includeTime = true
            
            return isoDateFormatter.stringFromDate(date)
        } ~> RAC(self.brewDesignerViewModel, "startTime")

        startTimeValueChangedSignal.subscribeNext {
            (next: AnyObject!) -> Void in
            let date = next as NSDate
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "YYYY.MM.dd. HH:mm"
            self.startTimeTextField.text = dateFormatter.stringFromDate(date)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func dismissKeyboard(anyObject: AnyObject!) {
        self.nameTextField.resignFirstResponder()
        self.startTimeTextField.resignFirstResponder()
        self.pickerBgView.hidden = true
    }

    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.brewDesignerViewModel.phases.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhaseCell", forIndexPath: indexPath) as PhaseCell
        if self.brewDesignerViewModel.phases.count > indexPath.row  {
            let phase = self.brewDesignerViewModel.phases[indexPath.row]
            cell.phaseLabel.text = "\(indexPath.row + 1). \(phase.min) min \(phase.temp) ˚C"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Phases"
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            if self.brewDesignerViewModel.phases.count > indexPath.row {
                var newPhases = self.brewDesignerViewModel.phases
                newPhases.removeAtIndex(indexPath.row)
                self.brewDesignerViewModel.setValue(newPhases, forKeyPath: "phases")
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let destinationPhase = self.brewDesignerViewModel.phases[destinationIndexPath.row]

        var newPhases = self.brewDesignerViewModel.phases
        newPhases[destinationIndexPath.row] = newPhases[sourceIndexPath.row]
        newPhases[sourceIndexPath.row] = destinationPhase
        self.brewDesignerViewModel.setValue(newPhases, forKeyPath: "phases")
        tableView.reloadData()
    }
    
    //MARK: UIGestureRecognizerDelegate

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if !touch.view.isDescendantOfView(nameTextField) {
            dismissKeyboard(nameTextField)
            return false
        }
        return true
    }
    
}