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
    
    var cocoaActionAdd: CocoaAction!

    init(brewDesignerViewModel: BrewDesignerViewModel) {
        self.brewDesignerViewModel = brewDesignerViewModel
        super.init(nibName:"BrewNewPhaseViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addAction = Action<Void, Void, NSError> {
            let newPhase = BrewPhase(jobEnd:"", min:Int(self.minStepper.value), temp:Float(self.tempStepper.value), tempReached:false, inProgress:false)
            var newPhases = self.brewDesignerViewModel.phases.value
            newPhases.append(newPhase)
            self.brewDesignerViewModel.phases(newPhases)
            return SignalProducer.empty
        }

        cocoaActionAdd = CocoaAction(addAction, input: ())
        addButton.addTarget(cocoaActionAdd, action: CocoaAction.selector, forControlEvents: .TouchUpInside)

        addAction.executing.producer
            .on( next: { executing in
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
            .start()

        let minStepperSignalProducer = minStepper.rac_signalForControlEvents(.ValueChanged).toSignalProducer()
            .map(self.mapStepper)
            .flatMapError(self.catcher)

        let tempStepperSignalProducer = tempStepper.rac_signalForControlEvents(.ValueChanged).toSignalProducer()
            .map(self.mapStepper)
            .flatMapError(self.catcher)
        
        let minTextSignalProducer = minTextField.rac_textSignalProducer()
            .filter(self.nonEmptyFilter)
            .map(self.toIntConverter)
            .flatMapError(self.catcher)

        let tempTextSignalProducer = tempTextField.rac_textSignalProducer()
            .filter(self.nonEmptyFilter)
            .map(self.toIntConverter)
            .flatMapError(self.catcher)

        SignalProducer(values: [minStepperSignalProducer, minTextSignalProducer])
            .flatten(.Merge)
            .on( next: { min in
                self.minStepper.value = Double(Int(min))
                self.minTextField.text = String(Int(min))
            })
            .start()
        
        SignalProducer(values: [tempStepperSignalProducer, tempTextSignalProducer])
            .flatten(.Merge)
            .on( next: { temp in
                self.tempStepper.value = Double(Int(temp))
                self.tempTextField.text = String(Int(temp))
            })
            .start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: helper functions
    
    func mapStepper(aStepper: AnyObject?) -> Int {
        if let stepper = aStepper as? UIStepper {
            return Int(stepper.value)
        }
        fatalError("stepper should be a UIStepper")
    }
    
    func catcher<E>(aInput: E) -> SignalProducer<Int, NoError> {
        return SignalProducer.empty
    }
    
    func nonEmptyFilter(aInput: String) -> Bool {
        return aInput != ""
    }
    
    func toIntConverter(aInput: String) -> Int {
        return Int(aInput)!
    }
    
}
