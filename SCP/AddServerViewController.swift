//
//  AddServerViewController.swift
//  SCP
//
//  Created by LD on 4/6/18.
//  Copyright © 2018 LD. All rights reserved.
//

import Eureka

class AddServerViewController: FormViewController {
    
    var serverForm:Form? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()                
        
        serverForm = form +++ Section()
            <<< NameRow(){ row in
                row.title = "Name"
                row.placeholder = "Name"
                row.tag = "name"
            }
            <<< TextRow(){
                $0.title = "Host"
                $0.placeholder = "URL or IP of Host"
                $0.tag = "host"
            }
            <<< IntRow(){
                $0.title = "Port"
                $0.placeholder = "Defaults to 22"
                $0.tag = "port"
            }
            <<< TextRow(){
                $0.title = "Username"
                $0.placeholder = "Defaults to root"
                $0.tag = "user"
            }
            <<< PasswordRow(){
                $0.title = "Password"
                $0.placeholder = "password"
                $0.tag = "pass"
            }
            +++ Section()
            <<< ButtonRow(){
                $0.title = "Add Server"
                }.onCellSelection {  cell, row in
                    let valuesDictionary = self.serverForm?.values()
                    let keychain = Keychain()
                    do {
                        let server = SSHServer(name: valuesDictionary!["name"] as! String,
                                               host: valuesDictionary!["host"] as! String,
                                               port: valuesDictionary!["port"] as! Int,
                                               user: valuesDictionary!["user"] as! String,
                                               pass: valuesDictionary!["pass"] as! String)

                        let jsonEncoder = JSONEncoder()
                        let jsonData = try jsonEncoder.encode(server)
                        let jsonString = String(data: jsonData, encoding: .utf8)
                        
                        try keychain.set(jsonString!, key: UUID().uuidString)
                        
                        _ = self.navigationController?.popViewController(animated: true)
                    } catch let error {
                        print("error: \(error)")
                    }
                }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
