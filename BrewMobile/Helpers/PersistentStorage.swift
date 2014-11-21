//
//  PersistentStorage.swift
//  SwiftStorageTest
//
//  Created by Ágnes Vásárhelyi on 31/08/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation

private var Instance = PersistentStorage()
private let StorageName = "BrewMobileStorage"

class PersistentStorage : NSObject {
    
    var host: String {
        didSet {
            self.save()
        }
    }
    
    class var sharedInstance : PersistentStorage {
        return Instance
    }
    
    override init() {
        host = "http://brewcore-demo.herokuapp.com/"
        super.init()
    }
    
    override class func initialize() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let storageData = userDefaults.dataForKey(StorageName) {
            let unarchiver = NSKeyedUnarchiver(forReadingWithData: storageData)
            Instance = unarchiver.decodeObject() as PersistentStorage
        } else {
            Instance = PersistentStorage()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        self.host = aDecoder.decodeObjectForKey("host") as String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(host, forKey: "host")
    }
    
    func save() {
        let lock = NSLock()
        lock.lock()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let storageData = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: storageData)
        
        archiver.encodeObject(Instance)
        archiver.finishEncoding()
        
        userDefaults.setObject(storageData, forKey: StorageName)
        userDefaults.synchronize()
        
        lock.unlock()
    }
    
}