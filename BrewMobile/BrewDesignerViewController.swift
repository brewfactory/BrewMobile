//
//  BrewDesignerViewController.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 07/11/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import UIKit

class BrewDesignerViewController : UIViewController, UITextFieldDelegate, BrewPhaseDesignerDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var phasesTableView: UITableView!
    @IBOutlet weak var startTimePicker: UIDatePicker!

    var name: String
    var startTime: String
    var phases: Array<(min: Int, temp: Int)>

    required init(coder aDecoder: NSCoder) {
        name = ""
        startTime = ""
        phases = []
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == startTimeTextField {
            textField.resignFirstResponder()
            
            let nowDate = NSDate()
            startTimePicker.minimumDate = nowDate
            startTimePicker.date = nowDate
            startTimePicker.hidden = false
        }
    }
    
    //MARK: BrewPhaseDesignerDelegate

    func addNewPhase(phase: (min: Int, temp: Int)) {
        phases.append(phase)
    }
    
    //MARK: IBAction methods

    @IBAction func datePickerDateDidChange(datePicker: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY.MM.dd. HH:mm"
        startTimeTextField.text = dateFormatter.stringFromDate(datePicker.date)
        let isoDateFormatter = ISO8601DateFormatter()
        startTime = isoDateFormatter.stringFromDate(datePicker.date)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addSegue" {
            let brewNewPhaseViewController: BrewNewPhaseViewController = segue.destinationViewController as BrewNewPhaseViewController
            brewNewPhaseViewController.delegate = self
        }
    }
    
}