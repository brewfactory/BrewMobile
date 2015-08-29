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

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addAction = Action<Void, Void, NSError> {
            let newPhase = BrewPhase(jobEnd:"", min:Int(self.minStepper.value), temp:Float(self.tempStepper.value), tempReached:false, inProgress:false)
            var newPhases = self.brewDesignerViewModel.phases.value
            newPhases.append(newPhase)
            self.brewDesignerViewModel.phases.put(newPhases)
            return SignalProducer.empty
        }

        cocoaActionAdd = CocoaAction(addAction, input: ())
        addButton.addTarget(cocoaActionAdd, action: CocoaAction.selector, forControlEvents: .TouchUpInside)

        addAction.executing.producer
            |> on( next: { executing in
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

        let minStepperSignalProducer = minStepper.rac_signalForControlEvents(.ValueChanged).toSignalProducer()
            |> map { aStepper in
                let stepper = aStepper as! UIStepper
                return Int(stepper.value)
            }
            |> catch { _ in SignalProducer<Int, NoError>.empty }

        let tempStepperSignalProducer = tempStepper.rac_signalForControlEvents(.ValueChanged).toSignalProducer()
            |> map { aStepper in
                let stepper = aStepper as! UIStepper
                return Int(stepper.value)
            }
            |> catch { _ in SignalProducer<Int, NoError>.empty }
        
        let minTextSignalProducer = minTextField.rac_textSignalProducer()
            |> filter( { $0 != "" } )
            |> map { minText in
                return minText.toInt()!
            }
            |> catch { _ in SignalProducer<Int, NoError>.empty }

        let tempTextSignalProducer = tempTextField.rac_textSignalProducer()
            |> filter( { $0 != "" } )
            |> map { tempText in
                return tempText.toInt()!
            }
            |> catch { _ in SignalProducer<Int, NoError>.empty }

        SignalProducer(values: [minStepperSignalProducer, minTextSignalProducer])
            |> flatten(.Merge)
            |> on( next: { min in
                self.minStepper.value = Double(Int(min))
                self.minTextField.text = String(Int(min))
            })
            |> start()
        
        SignalProducer(values: [tempStepperSignalProducer, tempTextSignalProducer])
            |> flatten(.Merge)
            |> on( next: { temp in
                self.tempStepper.value = Double(Int(temp))
                self.tempTextField.text = String(Int(temp))
            })
            |> start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
