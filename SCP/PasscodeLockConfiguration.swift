import UIKit
import PasscodeLock

class PasscodeLockConfiguration: PasscodeLockConfigurationType {
    var touchIdReason: String?
    
    let repository: PasscodeRepositoryType
    var passcodeLength = 4 // Specify the required amount of passcode digits
    var isTouchIDAllowed = true // Enable Touch ID
    var shouldRequestTouchIDImmediately = true // Use Touch ID authentication immediately
    var maximumInccorectPasscodeAttempts = 3 // Maximum incorrect passcode attempts
    
    init(repository: PasscodeRepositoryType) {
        self.repository = repository
    }
    
    init() {
        self.repository = UserDefaultsPasscodeRepository() // The repository that was created earlier
    }
}
