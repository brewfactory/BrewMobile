//
//  BrewDesignerViewController.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 07/11/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import UIKit

class PhaseCell: UITableViewCell {
    @IBOutlet weak var phaseLabel: UILabel!
}

class BrewDesignerViewController : UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, BrewPhaseDesignerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var phasesTableView: UITableView!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var pickerBgView: UIView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var syncButton: UIBarButtonItem!

    var name: String
    var startTime: String
    var phases: Array<BrewPhase>
    let nowDate = NSDate()

    required init(coder aDecoder: NSCoder) {
        name = ""
        startTime = ""
        phases = []
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editButton.target = self
        editButton.action = "editButtonPressed:"
        
        syncButton.target = self
        syncButton.action = "syncButtonPressed:"
        
        showFormattedTextDate(nowDate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showFormattedTextDate(date: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY.MM.dd. HH:mm"
        startTimeTextField.text = dateFormatter.stringFromDate(date)
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == startTimeTextField {
            nameTextField.resignFirstResponder()
            textField.resignFirstResponder()
            
            startTimePicker.minimumDate = nowDate
            startTimePicker.date = nowDate
            pickerBgView.hidden = false
            
            return false
        } else {
            pickerBgView.hidden = true
            
            return true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        syncButton.enabled = enableSyncButton()
    }
    
    func changeEditingModeOnTableView(editing: Bool) {
        phasesTableView.editing = editing
        editButton.title = editing ? "Done" : "Edit"
        
        let numberOfRows = phases.count
        if numberOfRows == 0 {
            editButton.enabled = false
            syncButton.enabled = false
        } else {
            editButton.enabled = true
        }
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = phases.count
        if numberOfRows == 0 {
            changeEditingModeOnTableView(false)
            editButton.enabled = false
            syncButton.enabled = false
        } else {
            editButton.enabled = true
        }
        
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhaseCell", forIndexPath: indexPath) as PhaseCell
        if phases.count > indexPath.row  {
            let phase = phases[indexPath.row]
            
            cell.phaseLabel.text = "\(indexPath.row + 1). \(phase.min) min \(phase.temp) ˚C"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            if phases.count > indexPath.row {
                phases.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                tableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let destinationPhase = phases[destinationIndexPath.row]
        
        phases[destinationIndexPath.row] =  phases[sourceIndexPath.row]
        phases[sourceIndexPath.row] = destinationPhase
        
        tableView.reloadData()
    }
    
    //MARK: BrewPhaseDesignerDelegate
    
    func addNewPhase(phase: BrewPhase) {
        phases.append(phase)
        phasesTableView.reloadData()
        enableSyncButton()
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
        //TODO: not formatting properly
        let isoDateFormatter = ISO8601DateFormatter()
        startTime = isoDateFormatter.stringFromDate(datePicker.date)
        enableSyncButton()
    }
    
    @IBAction func viewTapped() {
        dismissInputViews()
    }
    
    func dismissInputViews() {
        nameTextField.resignFirstResponder()
        startTimeTextField.resignFirstResponder()
        pickerBgView.hidden = true
    }
    
    func enableSyncButton() -> Bool {
       return (phases.count > 0 && countElements(nameTextField.text) > 0 && countElements(startTimeTextField.text) > 0)
    }
    
    //MARK: custom UIBarButtonItem actions
    
    func editButtonPressed(editButton: UIBarButtonItem) {
        changeEditingModeOnTableView(!phasesTableView.editing)
        dismissInputViews()
    }
    
    func syncButtonPressed(editButton: UIBarButtonItem) {
        dismissInputViews()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        changeEditingModeOnTableView(false)
        dismissInputViews()
        
        if segue.identifier == "addSegue" {
            let brewNewPhaseViewController: BrewNewPhaseViewController = segue.destinationViewController as BrewNewPhaseViewController
            brewNewPhaseViewController.delegate = self
        }
    }
    
}