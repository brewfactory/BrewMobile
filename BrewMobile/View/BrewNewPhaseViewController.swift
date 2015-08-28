//
//  BrewNewPhaseViewController.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 08/11/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import UIKit
import ReactiveCocoa

class BrewNewPhaseViewController : UIViewController {
    
    @IBOutlet weak var minTextField: UITextField!
    @IBOutlet weak var tempTextField: UITextField!
    @IBOutlet weak var minStepper: UIStepper!
    @IBOutlet weak var tempStepper: UIStepper!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var feedbackLabel: UILabel!

    let brewDesignerViewModel: BrewDesignerViewModel
    
    var min = Int(0)
    var temp = Int(20)
    
    var cocoaActionAdd: CocoaAction!

    init(brewDesignerViewModel: BrewDesignerViewModel) {
        self.brewDesignerViewModel = brewDesignerViewModel
        super.init(nibName:"BrewNewPhaseViewController", bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addAction = Action<Void, Void, NSError> {
            let newPhase = BrewPhase(jobEnd:"", min:self.min, temp:Float(self.temp), tempReached:false, inProgress:false)
            var newPhases = self.brewDesignerViewModel.phases.value
            newPhases.append(newPhase)
            self.brewDesignerViewModel.phases.put(newPhases)
            return SignalProducer.empty
        }

        cocoaActionAdd = CocoaAction(addAction, input: ())
        addButton.addTarget(cocoaActionAdd, action: CocoaAction.selector, forControlEvents: .TouchUpInside)

        addAction.executing.producer |> on( next: { executing in
            if executing {
                self.feedbackLabel.text = "Phase added"
                UIView.animateWithDuration(0.7, animations: { () -> Void in
                    self.feedbackLabel.alpha = 1.0
                    }, completion: { (Bool) -> Void in
                        UIView.animateWithDuration(0.7, animations: { () -> Void in
                            self.feedbackLabel.alpha = 0.0
                            }, completion: nil)
                })
            }
        })
        |> start()

        // MARK: RACSignals for controls
        
        func mappedStepperSignal(stepper: UIStepper) -> RACSignal {
            return stepper.rac_signalForControlEvents(.ValueChanged).map {
                (any: AnyObject!) -> AnyObject! in
                let stepper = any as! UIStepper
                
                return Int(stepper.value)
            }
        }
        
        func mappedTextSignal(textField: UITextField) -> RACSignal {
            return textField.rac_textSignal().map {
                (any: AnyObject!) -> AnyObject! in
                let text = any as! String
                
                return text.toInt()
            }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
