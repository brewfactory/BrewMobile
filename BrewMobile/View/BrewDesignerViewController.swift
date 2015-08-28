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

class BrewDesignerViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var phasesTableView: UITableView!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var pickerBgView: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!

    let brewDesignerViewModel: BrewDesignerViewModel
    let brewManager: BrewManager
    
    var cocoaActionTrash: CocoaAction!
    var cocoaActionEdit: CocoaAction!
    var cocoaActionAdd: CocoaAction!

    let tableViewEditing = MutableProperty(false)

    init(brewDesignerViewModel: BrewDesignerViewModel) {
        self.brewDesignerViewModel = brewDesignerViewModel
        self.brewManager = brewDesignerViewModel.brewManager
        
        super.init(nibName:"BrewDesignerViewController", bundle: nil)
        self.tabBarItem = UITabBarItem(title: "Designer", image: UIImage(named: "DesignerIcon"), tag: 0)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "PhaseCell", bundle: nil)
        phasesTableView.registerNib(nib, forCellReuseIdentifier: "PhaseCell")
        
        let addAction = Action<Void, Void, NSError>(enabledIf: MutableProperty<Bool>(true), {
            self.navigationController?.pushViewController(BrewNewPhaseViewController(brewDesignerViewModel: self.brewDesignerViewModel), animated: true)
            return SignalProducer.empty
        })

        let editAction = Action<Void, Void, NSError>(enabledIf: self.brewDesignerViewModel.hasPhases, {
            self.phasesTableView.editing = !self.phasesTableView.editing
            self.editButton.setTitle(self.phasesTableView.editing ? "Done" : "Edit", forState: .Normal)
            return SignalProducer.empty
        })

        let trashAction = Action<Void, Void, NSError>(enabledIf: self.brewDesignerViewModel.hasPhases, {
            self.brewDesignerViewModel.phases.put(PhaseArray())
            self.nameTextField.text = ""
            self.phasesTableView.reloadData()
            
            return SignalProducer.empty
        })

        cocoaActionTrash = CocoaAction(trashAction, input: ())
        cocoaActionEdit = CocoaAction(editAction, input: ())
        cocoaActionAdd = CocoaAction(addAction, input: ())

        syncButton.addTarget(self.brewDesignerViewModel.cocoaActionSync, action:CocoaAction.selector, forControlEvents: .TouchUpInside)
        trashButton.addTarget(cocoaActionTrash, action: CocoaAction.selector, forControlEvents: .TouchUpInside)
        editButton.addTarget(cocoaActionEdit, action: CocoaAction.selector, forControlEvents: .TouchUpInside)
        addButton.addTarget(cocoaActionAdd, action: CocoaAction.selector, forControlEvents: .TouchUpInside)

        self.brewManager.syncBrewAction.errors
            |> observeOn(UIScheduler())
            |> observe(next: { error in
                UIAlertView(title: "Error creating brew", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
            })

        self.brewDesignerViewModel.hasPhases.producer
            |> observeOn(UIScheduler())
            |> start( next: { hasPhases in
                if !self.phasesTableView.editing {
                    self.phasesTableView.reloadData()
                }

                if !(hasPhases as Bool) {
                    self.phasesTableView.editing = false
                }
            })

        self.brewDesignerViewModel.name <~ self.nameTextField.rac_textSignalProducer()

        let startTimeTextFieldSignalProducer = self.startTimeTextField.rac_signalForControlEvents(.EditingDidBegin).toSignalProducer()
        startTimeTextFieldSignalProducer
            |> start(next: { _ in
            self.dismissKeyboards()
        })
    
        self.pickerBgView.rac_hidden <~ startTimeTextFieldSignalProducer
            |> map { _ in return false }
            |> catch { _ in SignalProducer<Bool, NoError>.empty }

        let pickerDateSignalProducer = self.startTimePicker.rac_signalForControlEvents(.ValueChanged).toSignalProducer()
            |> map { picker in
                let datePicker = picker as! UIDatePicker
                return datePicker.date
            }
            |> catch { _ in SignalProducer<NSDate, NoError>.empty }
        
        pickerDateSignalProducer.start(next: { _ in
            self.dismissKeyboards()
        })

        self.startTimeTextField.rac_text <~ pickerDateSignalProducer
            |> map { date in
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "YYYY.MM.dd. HH:mm"
                return dateFormatter.stringFromDate(date as NSDate)
            }
            |> catch { _ in SignalProducer<String, NoError>.empty }

        self.brewDesignerViewModel.startTime <~ pickerDateSignalProducer
            |> map { date in
                let isoDateFormatter = ISO8601DateFormatter()
                isoDateFormatter.defaultTimeZone = NSTimeZone.defaultTimeZone()
                isoDateFormatter.includeTime = true
                
                return isoDateFormatter.stringFromDate(date)
            }
            |> catch { _ in SignalProducer<String, NoError>.empty }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func dismissKeyboards() {
        self.view.endEditing(true)
        self.pickerBgView.hidden = true
    }

    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.brewDesignerViewModel.phases.value.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhaseCell", forIndexPath: indexPath) as! PhaseCell
        if self.brewDesignerViewModel.phases.value.count > indexPath.row  {
            let phase = self.brewDesignerViewModel.phases.value[indexPath.row]
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
            if self.brewDesignerViewModel.phases.value.count > indexPath.row {
                var newPhases = self.brewDesignerViewModel.phases.value
                newPhases.removeAtIndex(indexPath.row)
                self.brewDesignerViewModel.setValue(newPhases, forKeyPath: "phases")
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let destinationPhase = self.brewDesignerViewModel.phases.value[destinationIndexPath.row]

        var newPhases = self.brewDesignerViewModel.phases.value
        newPhases[destinationIndexPath.row] = newPhases[sourceIndexPath.row]
        newPhases[sourceIndexPath.row] = destinationPhase
        self.brewDesignerViewModel.phases.put(newPhases)
        tableView.reloadData()
    }
    
    //MARK: UIGestureRecognizerDelegate

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if !touch.view.isDescendantOfView(nameTextField) && !touch.view.isDescendantOfView(pickerBgView) {
            dismissKeyboards()
            return false
        }
        return true
    }
    
}
