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

class BrewNewPhaseViewController : UIViewController {
    
    @IBOutlet weak var minTextField: UITextField!
    @IBOutlet weak var tempTextField: UITextField!
    @IBOutlet weak var minStepper: UIStepper!
    @IBOutlet weak var tempStepper: UIStepper!
    @IBOutlet weak var addButton: UIButton!
    
    let brewViewModel: BrewViewModel
    
    var min = Int(0)
    var temp = Int(20)

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
            let newPhase = BrewPhase(jobEnd:"", min:self.min, temp:Float(self.temp), tempReached:false, inProgress:false)
            var newPhases = self.brewViewModel.phases
            newPhases.append(newPhase)
            self.brewViewModel.setValue(newPhases, forKeyPath: "phases")
            return RACSignal.empty()
        }

        let minStepperSignal = mappedStepperSignal(minStepper)
        let tempStepperSignal = mappedStepperSignal(tempStepper)

        let minTextSignal = mappedTextSignal(minTextField)
        let tempTextSignal = mappedTextSignal(tempTextField)

        minTextSignal.merge(minStepperSignal).subscribeNext {
                (next: AnyObject!) -> Void in
            if let min = next as? Int {
                self.min = min
                self.minStepper.value = Double(self.min)
                self.minTextField.text = String(self.min)
            }
        }

        tempTextSignal.merge(tempStepperSignal).subscribeNext {
                (next: AnyObject!) -> Void in
            if let temp = next as? Int {
                self.temp = temp
                self.tempStepper.value = Double(self.temp)
                self.tempTextField.text = String(self.temp)
            }
        }
    }

    // MARK: RACSignals for controls

    func mappedStepperSignal(stepper: UIStepper) -> RACSignal {
        return stepper.rac_signalForControlEvents(.ValueChanged).map {
            (any: AnyObject!) -> AnyObject! in
            let stepper = any as UIStepper

            return Int(stepper.value)
        }
    }

    func mappedTextSignal(textField: UITextField) -> RACSignal {
        return textField.rac_textSignal().map {
            (any: AnyObject!) -> AnyObject! in
            let text = any as String

            return text.toInt()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: IBAction methods
    
    @IBAction func viewTapped() {
        minTextField.resignFirstResponder()
        tempTextField.resignFirstResponder()
    }

}