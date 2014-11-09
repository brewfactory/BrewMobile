//
//  BrewNewPhaseViewController.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 08/11/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import UIKit

protocol BrewPhaseDesignerDelegate {
    func addNewPhase(phase: (min: Int, temp: Int))
}

class BrewNewPhaseViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var minTextField: UITextField!
    @IBOutlet weak var tempTextField: UITextField!
    @IBOutlet weak var minStepper: UIStepper!
    @IBOutlet weak var tempStepper: UIStepper!
    
    var delegate: BrewPhaseDesignerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        minStepper.value = Double(minTextField.text.toInt()!)
        tempStepper.value = Double(tempTextField.text.toInt()!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setValueToStepper(value: Double, stepper: UIStepper) {
        stepper.value = value
    }
    
    func setValueToTextField(value: Int, textField: UITextField) {
        textField.text = String(value)
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    //MARK: IBAction methods
    
    @IBAction func stepperValueDidChange(stepper: UIStepper) {
        setValueToTextField(Int(stepper.value), textField: stepper == minStepper ? minTextField : tempTextField)
    }
    
    @IBAction func textFieldDidChange(textField: UITextField) {
        setValueToStepper(Double(textField.text.toInt()!), stepper: textField == minTextField ? minStepper : tempStepper)
    }
    
    @IBAction func addButtonPressed(button: UIButton) {
        delegate.addNewPhase((min: Int(minStepper.value), temp: Int(tempStepper.value)))
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}