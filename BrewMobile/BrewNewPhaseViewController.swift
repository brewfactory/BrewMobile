//
//  BrewNewPhaseViewController.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 08/11/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import UIKit
import ReactiveCocoa

protocol BrewPhaseDesignerDelegate {
    func addNewPhase(phase: BrewPhase)
}

class BrewNewPhaseViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var minTextField: UITextField!
    @IBOutlet weak var tempTextField: UITextField!
    @IBOutlet weak var minStepper: UIStepper!
    @IBOutlet weak var tempStepper: UIStepper!
    @IBOutlet weak var addButton: UIButton!
    
    let brewViewModel: BrewViewModel
    
    init(brewViewModel: BrewViewModel) {
        self.brewViewModel = brewViewModel
        super.init(nibName:"BrewNewPhaseViewController", bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton.rac_command = RACCommand() {
            (any:AnyObject!) -> RACSignal in
            let newPhase = BrewPhase(jobEnd:"", min:Int(self.minStepper.value), temp:Float(self.tempStepper.value), tempReached:false, inProgress:false)
            var newPhases = self.brewViewModel.phases
            newPhases.append(newPhase)
            self.brewViewModel.setValue(newPhases, forKeyPath: "phases")
            return RACSignal.empty()
        }
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
        setValueToStepper(Double(countElements(textField.text) > 0 ? textField.text.toInt()! : 0), stepper: textField == minTextField ? minStepper : tempStepper)
    }
    
    @IBAction func viewTapped() {
        minTextField.resignFirstResponder()
        tempTextField.resignFirstResponder()
    }

}