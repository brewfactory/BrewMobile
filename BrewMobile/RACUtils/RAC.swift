//
//  RAC.swift
//
//  Created by Colin Eberhardt on 15/07/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

import Foundation
import ReactiveCocoa
import UIKit

extension UITextField {
    func rac_textSignalProducer() -> SignalProducer<String, NoError> {
        return self.rac_textSignal().toSignalProducer()
            |> map { $0 as! String }
            |> catch { _ in SignalProducer<String, NoError>.empty }
    }
}

// a struct that replaces the RAC macro
struct RAC  {
  var target : NSObject!
  var keyPath : String!
  var nilValue : AnyObject!
  
  init(_ target: NSObject!, _ keyPath: String, nilValue: AnyObject? = nil) {
    self.target = target
    self.keyPath = keyPath
    self.nilValue = nilValue
  }
  
  
  func assignSignal(signal : RACSignal) {
    signal.setKeyPath(self.keyPath, onObject: self.target, nilValue: self.nilValue)
  }
}

infix operator ~> {}
func ~> (signal: RACSignal, rac: RAC) {
  rac.assignSignal(signal)
}

struct AssociationKey {
    static var hidden: UInt8 = 1
    static var date: UInt8 = 2
    static var text: UInt8 = 3
}

func lazyAssociatedProperty<T: AnyObject>(host: AnyObject, key: UnsafePointer<Void>, factory: ()->T) -> T {
    return objc_getAssociatedObject(host, key) as? T ?? {
        let associatedProperty = factory()
        objc_setAssociatedObject(host, key, associatedProperty, UInt(OBJC_ASSOCIATION_RETAIN))
        return associatedProperty
        }()
}

func lazyMutableProperty<T>(host: AnyObject, key: UnsafePointer<Void>, setter: T -> (), getter: () -> T) -> MutableProperty<T> {
    return lazyAssociatedProperty(host, key) {
        var property = MutableProperty<T>(getter())
        property.producer
            .start(next: {
                newValue in
                setter(newValue)
            })
        return property
    }
}

extension UIDatePicker {
    public var rac_date: MutableProperty<NSDate> {
        return lazyMutableProperty(self, &AssociationKey.date, { self.date = $0 }, { self.date  })
    }
}

extension UIView {
    public var rac_hidden: MutableProperty<Bool> {
        return lazyMutableProperty(self, &AssociationKey.hidden, { self.hidden = $0 }, { self.hidden  })
    }
}

extension UILabel {
    public var rac_text: MutableProperty<String> {
        return lazyMutableProperty(self, &AssociationKey.text, { self.text = $0 }, { self.text ?? "" })
    }
}

extension UITextField {
    public var rac_text: MutableProperty<String> {
        return lazyAssociatedProperty(self, &AssociationKey.text) {
            
            self.addTarget(self, action: "changed", forControlEvents: UIControlEvents.EditingChanged)
            
            var property = MutableProperty<String>(self.text ?? "")
            property.producer
                .start(next: {
                    newValue in
                    self.text = newValue
                })
            return property
        }
    }
    
    func changed() {
        rac_text.value = self.text
    }
}
