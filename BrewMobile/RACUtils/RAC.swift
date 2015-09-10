//
//  RAC.swift
//
//  Created by Colin Eberhardt on 15/07/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//
//  Original source can be found at:
//  https://github.com/ColinEberhardt/ReactiveTwitterSearch/blob/master/ReactiveTwitterSearch/Util/UIKitExtensions.swift
//

import Foundation
import ReactiveCocoa
import UIKit

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

extension UIView {
    public var rac_hidden: MutableProperty<Bool> {
        return lazyMutableProperty(self, &AssociationKey.hidden, { self.hidden = $0 }, { self.hidden })
    }
}

extension UILabel {
    public var rac_text: MutableProperty<String> {
        return lazyMutableProperty(self, &AssociationKey.text, { self.text = $0 }, { self.text ?? "" })
    }
}


extension UITextField {
    func rac_textSignalProducer() -> SignalProducer<String, NoError> {
        return self.rac_textSignal().toSignalProducer()
            .map { $0 as! String }
            .flatMapError { _ in SignalProducer<String, NoError>.empty }
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
