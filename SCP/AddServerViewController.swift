//
//  AddServerViewController.swift
//  SCP
//
//  Created by LD on 4/6/18.
//  Copyright © 2018 LD. All rights reserved.
//

import Eureka
import GenericPasswordRow

class AddServerViewController: FormViewController {
    
    var serverForm: Form? = nil
    var editingItem: SSHServer?
    var editingItemJSON: String?
    var editingItemUUID: String?
    var keychain:Keychain? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keychain = Keychain()
        
        
        
        if let detail = editingItemJSON {
            do {
                let jsonDecoder = JSONDecoder()
                let server = try jsonDecoder.decode(SSHServer.self, from: detail.data(using: .utf8)!)
                
                editingItem = server
            } catch let error {
                print("error: \(error)")
            }
        }
        
        serverForm = form +++ Section()
            <<< NameRow() { row in
                row.title = "Name"
                row.placeholder = "Name"
                row.tag = "name"
                
                row.cell.textField?.autocorrectionType = UITextAutocorrectionType.no
                row.cell.textField?.autocapitalizationType = UITextAutocapitalizationType.none
                
                if editingItem != nil {
                    row.value = editingItem?.name
                }
            }
            <<< TextRow() {
                $0.title = "Host"
                $0.placeholder = "URL or IP of Host"
                $0.tag = "host"
                
                $0.cell.textField?.autocorrectionType = UITextAutocorrectionType.no
                $0.cell.textField?.autocapitalizationType = UITextAutocapitalizationType.none
                
                if editingItem != nil {
                    $0.value = editingItem?.host
                }
            }
            <<< IntRow() {
                $0.title = "Port"
                $0.placeholder = "Defaults to 22"
                $0.tag = "port"
                
                if editingItem != nil {
                    $0.value = editingItem?.port
                }
            }
            <<< TextRow() {
                $0.title = "Username"
                $0.placeholder = "Defaults to root"
                $0.tag = "user"
                
                $0.cell.textField?.autocorrectionType = .no
                $0.cell.textField?.autocapitalizationType = .none
                
                if editingItem != nil {
                    $0.value = editingItem?.user
                }
            }
            +++ Section()
            <<< GenericPasswordRow() {
                $0.title = "Password"
                $0.placeholder = "password with our without keys"
                $0.tag = "pass"
                $0.cell.hintLabel = nil
                
                if editingItem != nil {
                    $0.value = editingItem?.pass
                }
            }
            <<< LabelRow() {
                $0.title = "Password and Key auth can be used together or separetly"
                $0.cell.textLabel?.numberOfLines = 0
            }
            +++ Section()
            <<< LabelRow() {
                $0.title = "Private Key"
                $0.cell.textLabel?.numberOfLines = 0
            }
            <<< TextAreaRow() {
                $0.title = "Private Key"
                $0.placeholder = "Private key"
                $0.tag = "privatekey"
                
                $0.cell.textView.autocorrectionType = .no
                $0.cell.textView.autocapitalizationType = .none
                
                if editingItem != nil {
                    $0.value = editingItem?.privkey
                }
            }
            <<< LabelRow() {
                $0.title = "Public Key"
                $0.cell.textLabel?.numberOfLines = 0
            }
            <<< TextAreaRow() {
                $0.title = "Public Key"
                $0.placeholder = "Public key"
                $0.tag = "publickey"
                
                $0.cell.textView.autocorrectionType = .no
                $0.cell.textView.autocapitalizationType = .none
                
                if editingItem != nil {
                    $0.value = editingItem?.pubkey
                }
            }
            <<< GenericPasswordRow() {
                $0.title = "Passprase"
                $0.placeholder = "leave empty if not needed"
                $0.tag = "passprase"
                $0.cell.hintLabel = nil
                
                if editingItem != nil {
                    $0.value = editingItem?.prase
                }
            }
            +++ Section()
            <<< ButtonRow() {
                $0.title = "Add Server"
                if editingItem != nil {
                    $0.title = "Edit Server"
                }
                }.onCellSelection { cell, row in
                    do {
                        let nameRow: NameRow? = self.serverForm?.rowBy(tag: "name")
                        let portRow: IntRow? = self.serverForm?.rowBy(tag: "port")
                        let userRow: TextRow? = self.serverForm?.rowBy(tag: "user")
                        let hostRow: TextRow? = self.serverForm?.rowBy(tag: "host")
                        let passRow: GenericPasswordRow? = self.serverForm?.rowBy(tag: "pass")
                        
                        let privkey: TextAreaRow? = self.serverForm?.rowBy(tag: "privatekey")
                        let pubkey: TextAreaRow? = self.serverForm?.rowBy(tag: "publickey")
                        let prase: GenericPasswordRow? = self.serverForm?.rowBy(tag: "passprase")
                        
                        let server = SSHServer(name: nameRow?.value ?? "Unknown",
                                               host: hostRow?.value ?? "example.com",
                                               port: portRow?.value ?? 22,
                                               user: userRow?.value ?? "root",
                                               pass: passRow?.value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                                               privkey: privkey?.value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                                               pubkey: pubkey?.value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                                               prase: prase?.value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        )
                        
                        let jsonEncoder = JSONEncoder()
                        let jsonData    = try jsonEncoder.encode(server)
                        let jsonString  = String(data: jsonData, encoding: .utf8)
                        
                        let uuid = self.editingItemUUID ?? UUID().uuidString
                        try self.keychain!.set(jsonString!, key: uuid)
                        
                        _ = self.navigationController?.popViewController(animated: true)
                    } catch let error {
                        print("error: \(error)")
                    }
        }
        
    }
        
}
