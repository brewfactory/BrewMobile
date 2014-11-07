//
//  BrewDesignerViewController.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 07/11/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import UIKit

class BrewDesignerViewController : UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var phasesTableView: UITableView!
    @IBOutlet weak var startTimePicker: UIDatePicker!

    var name: String
    var startTime: String
    var phases: PhaseArray

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
        if (textField == startTimeTextField) {
            let nowDate = NSDate()
            startTimePicker.minimumDate = nowDate
            startTimePicker.date = nowDate
            self.view.addSubview(startTimePicker)
        }
    }
    
    //MARK: IBAction methods

    @IBAction func datePickerDateDidChange(datePicker: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY.MM.dd. HH:mm"
        startTimeTextField.text = dateFormatter.stringFromDate(datePicker.date)
        let isoDateFormatter = ISO8601DateFormatter()
        startTime = isoDateFormatter.stringFromDate(datePicker.date)
    }
    
}