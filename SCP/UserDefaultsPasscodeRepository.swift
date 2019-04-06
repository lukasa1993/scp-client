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
        let passcode = try! defaults.get(passcodeKey)
        let jsonDecode = JSONDecoder()
        if(passcode == nil) {
            return nil
        }
        
        do {
            return try jsonDecode.decode(Array<String>.self, from: passcode!.data(using: .utf8)!)
        } catch {
            return nil
        }
    }
    
    func savePasscode(_ passcode: [String]) {
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(passcode)
        try! defaults.set(jsonData, key: passcodeKey)
    }
    
    func deletePasscode() {
        try! defaults.remove(passcodeKey)
    }
}
