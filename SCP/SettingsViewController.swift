//
//  SettingsViewController.swift
//  SCP
//
//  Created by LD on 3/29/19.
//  Copyright © 2019 LD. All rights reserved.
//

import Eureka
import PasscodeLock

class SettingsViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let folder_first  = (UserDefaults.standard.object(forKey: "folder_first") as? Bool) ?? false
        let hidden        = (UserDefaults.standard.object(forKey: "show_hidden_files") as? Bool) ?? false
        let repo          = UserDefaultsPasscodeRepository()
        let configuration = PasscodeLockConfiguration(repository: repo)
        
        var skipBioChange = false
        
        form +++ Section("General")
            <<< SwitchRow("show_hidden") { row in
                row.title = "Show Hidden Files"
                row.value = hidden
                }.onChange { row in
                    UserDefaults.standard.set(row.value, forKey: "show_hidden_files")                    
            }
            <<< SwitchRow("folder_first") { row in
                row.title = "Sort Folders First"
                row.value = folder_first
                }.onChange { row in
                    UserDefaults.standard.set(row.value, forKey: "folder_first")
            }
            +++ Section("Security")
            <<< SwitchRow("bio_auth") { row in
                row.title = "Biometric Auth"
                row.value = repo.hasPasscode
                }.onChange { row in
                    if(skipBioChange) {
                        skipBioChange = false
                        return
                    }
                    let isDeleting = !row.value!
                    var wasSuccsess = true
                    let passcodeViewController = PasscodeLockViewController(state: row.value! ? .setPasscode : .removePasscode , configuration: configuration)
                    passcodeViewController.successCallback = { lock in
                        wasSuccsess = true
                        if(isDeleting) {
                            lock.repository.deletePasscode()
                        }
                        if(row.value != lock.repository.hasPasscode) {
                            skipBioChange = true
                        }
                        row.value = lock.repository.hasPasscode
                        row.updateCell()
                    }
                    passcodeViewController.dismissCompletionCallback = {
                        if(wasSuccsess) {
                            wasSuccsess = false
                            return
                        }
                        if(row.value != repo.hasPasscode) {
                            skipBioChange = true
                        }
                        row.value = repo.hasPasscode
                        row.updateCell()
                    }
                    self.present(passcodeViewController, animated: true, completion: nil)
            }
            +++ Section("Premium")
            <<< SwitchRow("dark_mode"){
                $0.title = "Dark Mode (Comming soon…)"
                $0.disabled = true
        }
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
