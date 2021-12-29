//
//  UserDefaultsPasscodeRepository.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/29/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import PasscodeLock



class UserDefaultsPasscodeRepository: PasscodeRepositoryType {
    
    fileprivate var passcodeKey = "passcode.lock.passcode"
    
    @available(macCatalyst 14.0, *)
    fileprivate lazy var defaults: Keychain = {
        return Keychain(service: "passcode_lock")
    }()
    
    var hasPasscode: Bool {
        
        if passcode != nil {
            return true
        }
        
        return false
    }
    
    var passcode: [String]? {
        var passcode = ""
        if #available(macCatalyst 14.0, *) {
            let storedPasscode = try! defaults.get(passcodeKey)
            if(storedPasscode != nil) {
                passcode = storedPasscode!
            }
        } else {
            // Fallback on earlier versions
        }
        let jsonDecode = JSONDecoder()
        do {
            return try jsonDecode.decode(Array<String>.self, from: passcode.data(using: String.Encoding.utf8)!)
        } catch {
            return nil
        }
    }
    
    func savePasscode(_ passcode: [String]) {
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(passcode)
        if #available(macCatalyst 14.0, *) {
            try! defaults.set(jsonData, key: passcodeKey)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func deletePasscode() {
        if #available(macCatalyst 14.0, *) {
            try! defaults.remove(passcodeKey)
        } else {
            // Fallback on earlier versions
        }
    }
}
