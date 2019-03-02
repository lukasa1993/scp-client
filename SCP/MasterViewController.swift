//
//  MasterViewController.swift
//  SCP
//
//  Created by LD on 4/6/18.
//  Copyright © 2018 LD. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    var keys = [String]()
    var keychain:Keychain? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        
        keychain = Keychain()
        keys = (keychain?.allKeys())!;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if((keychain) != nil) {
            keys = (keychain?.allKeys())!;
            tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        performSegue(withIdentifier: "add_server", sender: sender)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                do {
                    let Key = keys[indexPath.row]
                    let Value = try keychain?.get(Key);
                    controller.detailItem = Value!
                    controller.detailItemUUID = Key
                } catch _ {
                    controller.detailItem = "Key Doesn't Exist"
                }
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                self.tableView.deselectRow(at: indexPath, animated: false)
            }
        } else if segue.identifier == "editServer" {
            let controller = segue.destination as! AddServerViewController
            do {
                let Key = keys[segue.source.view.tag]
                let Value = try keychain?.get(Key);
                controller.editingItemJSON = Value!
                controller.editingItemUUID = Key
            } catch _ {
                controller.editingItemJSON = "Key Doesn't Exist"
            }
            controller.navigationItem.leftItemsSupplementBackButton = true
            
        }
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetail", sender: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let Key = keys[indexPath.row]
        do {
            let Value = try keychain?.get(Key);
            let jsonDecoder = JSONDecoder()
            let server = try jsonDecoder.decode(SSHServer.self, from: (Value?.data(using: .utf8))!)
            cell.textLabel!.text = server.name
            cell.detailTextLabel!.text = server.host + ":" + String(server.port)
            cell.accessoryView?.tag = indexPath.row;
        } catch _ {
            cell.textLabel!.text = "Corrupted!"
            cell.detailTextLabel!.text = Key
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try keychain?.remove(keys[indexPath.row])
                keys.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch let error {
                print(error)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
}

