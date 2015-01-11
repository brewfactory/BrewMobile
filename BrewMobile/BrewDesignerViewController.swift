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

class BrewDesignerViewController : UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, BrewPhaseDesignerDelegate, UIGestureRecognizerDelegate {

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

    let brewViewModel: BrewViewModel
    
    init(brewViewModel: BrewViewModel) {
        self.brewViewModel = brewViewModel
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
        
        let dismissInputViewsSignal = RACSignal.createSignal({ _ in
            self.nameTextField.resignFirstResponder()
            self.startTimeTextField.resignFirstResponder()
            return RACDisposable()
        })
        
        dismissInputViewsSignal ~> RAC(self.pickerBgView, "hidden")
        
        editButton.rac_command = RACCommand(enabled: self.brewViewModel.hasPhasesSignal) {
            (any:AnyObject!) -> RACSignal in
            self.phasesTableView.editing = !self.phasesTableView.editing
            return RACSignal.empty()
        }

        syncButton.rac_command = RACCommand(enabled: self.brewViewModel.validBeerSignal) {
            (any:AnyObject!) -> RACSignal in
            return self.brewViewModel.syncCommand.execute(self)
        }
        
        self.brewViewModel.hasPhasesSignal.subscribeNext {
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
        
        trashButton.rac_command = RACCommand() {
            (any:AnyObject!) -> RACSignal in
            // TODO: refresh new date
            self.phasesTableView.reloadData()
            return RACSignal.empty()
        }
        
        addButton.rac_command = RACCommand() {
            (any:AnyObject!) -> RACSignal in
            self.navigationController?.pushViewController(BrewNewPhaseViewController(brewViewModel: self.brewViewModel), animated: true)
            return RACSignal.empty()
        }

        self.nameTextField.rac_textSignal() ~> RAC(self.brewViewModel, "name")
        self.startTimeTextField.rac_textSignal() ~> RAC(self.brewViewModel, "startTime")

        // TODO: refresh new date
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showFormattedTextDate(date: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY.MM.dd. HH:mm"
        startTimeTextField.text = dateFormatter.stringFromDate(date)
    }
    
    func createISO8601FormattedDate(date: NSDate) -> String {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.defaultTimeZone = NSTimeZone.defaultTimeZone()
        isoDateFormatter.includeTime = true
        return isoDateFormatter.stringFromDate(date)
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == startTimeTextField {
            nameTextField.resignFirstResponder()
            textField.resignFirstResponder()
            
            startTimePicker.minimumDate = NSDate()
            startTimePicker.date = NSDate()
            pickerBgView.hidden = false
            
            return false
        } else {
            pickerBgView.hidden = true
            
            return true
        }
    }

    func changeEditingModeOnTableView(editing: Bool) {
        phasesTableView.editing = editing
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.brewViewModel.phases.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhaseCell", forIndexPath: indexPath) as PhaseCell
        if self.brewViewModel.phases.count > indexPath.row  {
            let phase = self.brewViewModel.phases[indexPath.row]
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
            if self.brewViewModel.phases.count > indexPath.row {
                var newPhases = self.brewViewModel.phases
                newPhases.removeAtIndex(indexPath.row)
                self.brewViewModel.setValue(newPhases, forKeyPath: "phases")
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let destinationPhase = self.brewViewModel.phases[destinationIndexPath.row]

        var newPhases = self.brewViewModel.phases
        newPhases[destinationIndexPath.row] =  newPhases[sourceIndexPath.row]
        newPhases[sourceIndexPath.row] = destinationPhase
        self.brewViewModel.setValue(newPhases, forKeyPath: "phases")
        tableView.reloadData()
    }
    
    //MARK: BrewPhaseDesignerDelegate
    
    func addNewPhase(phase: BrewPhase) {
        self.brewViewModel.phases.append(phase)
        phasesTableView.reloadData()
    }
    
    //MARK: UIGestureRecognizerDelegate

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view.isDescendantOfView(phasesTableView) && phasesTableView.editing {
            return false
        }
        return true
    }
    
    //MARK: IBAction methods

    @IBAction func datePickerDateDidChange(datePicker: UIDatePicker) {
        showFormattedTextDate(datePicker.date)
        self.brewViewModel.startTime = createISO8601FormattedDate(datePicker.date)
    }
    
}