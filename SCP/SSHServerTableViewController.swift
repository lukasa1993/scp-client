//
//  SSHServerTableViewController.swift
//  SCP
//
//  Created by LD on 4/6/18.
//  Copyright © 2018 LD. All rights reserved.
//

import UIKit
import NMSSH

class SSHServerTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NMSSHChannelDelegate {
    
    var tableView:UITableView? = nil
    var SSHServer:SSHServer? = nil
    var SSHSession:NMSSHSession? = nil
    var isLeft = false
    var isStarted = false
    var isConnecting = false
    var objects = [[String:String]]()
    var pwd:String = ""
    var sidePWD:String = ""
    var queries = [String]()
    var presenter: ((_ viewControllerToPresent: UIAlertController, _ flag: Bool, _ completion: (() -> Void)? ) -> ())?
    var exit: (()->())?
    var sideListener: ((_ path:String) -> ())?
    var executionListener: (()->())?
    var sshQueue:DispatchQueue?
    var serverUUID:String!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func start() {
        if(isStarted) {
            return
        }
        isConnecting = true
        self.title = SSHServer?.name
        
        DispatchQueue.main.async {
            self.tableView?.dataSource = self;
            self.tableView?.delegate = self;
            self.tableView?.register(UITableViewCell.self, forCellReuseIdentifier: self.isLeft ? "LeftTableCell" : "RightTableCell")
        }
        
        if(isLeft) {
            pwd = (UserDefaults.standard.object(forKey: self.serverUUID + "_last_path_left") as? String) ?? ""
        } else {
            pwd = (UserDefaults.standard.object(forKey: self.serverUUID + "_last_path_right") as? String) ?? ""
        }
        
        SSHSession = NMSSHSession.connect(toHost: SSHServer?.host, port: (SSHServer?.port)!, withUsername: SSHServer?.user)
        if (SSHSession?.isConnected)! {
            if (SSHServer?.pass.count)! > 0 {
                SSHSession?.authenticate(byPassword: SSHServer?.pass)
            }
            
            if(checkAuth() == false) {
                SSHSession?.authenticateBy(inMemoryPublicKey: SSHServer?.pubkey, privateKey: SSHServer?.privkey, andPassword: SSHServer?.prase)
                if(checkAuth() == false) {
                    if self.self.isLeft {
                        print("Left Cant Connect")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            let alert = UIAlertController(title: "Error", message: "Can't Esatablish connection to server, please check credentials", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Go Back", style: .default, handler: { action in
                                self.exit!()
                            }))
                            self.presenter!(alert, true,  nil)
                            
                        }
                    } else {
                        print("Right Cant Connect")
                    }
                }
            }
        }
        
        isConnecting = false
    }
    
    func checkAuth() -> Bool {
        if (SSHSession?.isAuthorized)! {
            print("Authentication succeeded");
            isStarted = true;
            
            changeDir(path: pwd)
            
            return true
        }
        
        return false
    }
    
    public func checkConnecting() -> Bool {
        return isConnecting
    }
    
    public func stop() {
        SSHSession?.channel.closeShell()
        SSHSession?.disconnect()
    }
    
    public func reconnect() {
        stop()
        isStarted = false
        start()
    }
    
    public func sideReceived(path:String) {
        sidePWD = path
    }
    
    public func handleAfterExecution() {
        changeDir(path: pwd)
    }
    
    private func listDirectory() {
        do {
            let list = try SSHSession?.channel.execute("cd \"" + pwd + "\" && ls -1")
            let dirs = try SSHSession?.channel.execute("cd \"" + pwd + "\" && ls -d1 */")
            
            parseListing(all: list!, dirs: dirs!);
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        } catch let error {
            print("error: \(error)")
        }
    }
    
    private func parseListing(all:String, dirs:String) {
        let allItems = all.split(separator: "\n")
        let allDirs = dirs.split(separator: "\n")
        
        
        for item in allItems {
            var isDir = false
            for dir in allDirs {
                if(dir.range(of: item) != nil) {
                    isDir = true
                }
            }
            
            if(isDir) {
                objects.append(["name":String(item), "type":"folder"])
            } else {
                objects.append(["name":String(item), "type":"file"])
            }
        }
        
    }
    
    
    private func changeDir(path:String) {
        do {
            pwd = (try SSHSession?.channel.execute("cd \""  + pwd + "\" && cd \"" + path + "\" && pwd"))!
            pwd = pwd.trimmingCharacters(in: .whitespacesAndNewlines)
            if(isLeft) {
                UserDefaults.standard.set(pwd, forKey: self.serverUUID + "_last_path_left")
            } else {
                UserDefaults.standard.set(pwd, forKey: self.serverUUID + "_last_path_right")
            }
            sideListener!(pwd)
            
            objects = []
            if(pwd != "/") {
                objects = [["name":"..", "type":"folder"]]
            }
            listDirectory()
        } catch let error {
            print("error: \(error)")
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: isLeft ? "LeftTableCell" : "RightTableCell", for: indexPath)
        let item = objects[indexPath.row];
        
        cell.textLabel?.text = item["name"]
        if(item["type"] == "folder") {
            cell.imageView?.image = UIImage.init(icon: .fontAwesome(.folder), size: CGSize(width: 35, height: 35))
        } else if(item["type"] == "file") {
            cell.imageView?.image = UIImage.init(icon: .fontAwesome(.file), size: CGSize(width: 35, height: 35))
        }
        let holdForAction = UILongPressGestureRecognizer(target: self, action: #selector(SSHServerTableViewController.longPressFolder));
        cell.addGestureRecognizer(holdForAction)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = objects[indexPath.row];
        
        if(item["type"] == "folder") {
            changeDir(path: item["name"]!)
        } else if(item["type"] == "file") {
            handleAction(item, indexPath: indexPath)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc public func longPressFolder(sender: UILongPressGestureRecognizer) {
        let point: CGPoint = sender.location(in: self.tableView);
        let indexPath: NSIndexPath = self.tableView!.indexPathForRow(at: point)! as NSIndexPath;
        let item = objects[indexPath.row];
        handleAction(item, indexPath: indexPath as IndexPath);
    }
    
    
    private func handleAction(_ item:[String:String], indexPath:IndexPath) {
        if(item["name"] == "..") {
            return
        }
        
        let alert = UIAlertController(title: "Action On " + item["name"]!,
                                      message: "Move/Copy to: " + sidePWD,
                                      preferredStyle: .actionSheet)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = tableView?.cellForRow(at: indexPath)
            popoverController.sourceRect = (popoverController.sourceView?.bounds)!
        }
        
        if(item["type"] == "file") {
            alert.addAction(UIAlertAction(title: "Execute", style: .default, handler: { (action) in
                let runArguments = UIAlertController(title: "Executing " + item["name"]!,
                                                     message: "Supply arguments if needed",
                                                     preferredStyle: .alert)
                
                runArguments.addTextField { (textField) in
                    textField.placeholder = "arguments"
                }
                
                runArguments.addAction(UIAlertAction(title: "Run", style: .default, handler: { (action) in
                    self.handleRun(path: self.pwd + "/" + item["name"]!, args: runArguments.textFields![0].text!)
                }))
                
                runArguments.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                self.presenter!(runArguments, true, nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Copy", style: .default, handler: { (action) in
            self.handleCopy(from: self.pwd + "/" + item["name"]!, to: self.sidePWD)
        }))
        
        alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { (action) in
            let renameAlert = UIAlertController(title: "Renaming " + item["name"]!,
                                                message: "Provide New Name",
                                                preferredStyle: .alert)
            
            renameAlert.addTextField { (textField) in
                textField.placeholder = "new name"
                textField.text = item["name"]
            }
            
            renameAlert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { (action) in
                self.handleMove(from: self.pwd + "/" + item["name"]!, to: self.pwd + "/" + renameAlert.textFields![0].text!)
            }))
            
            renameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            
            self.presenter!(renameAlert, true, nil)
        }))
        
        alert.addAction(UIAlertAction(title: "View", style: .default, handler: { (action) in
            self.handleView(path: self.pwd + "/" + item["name"]!)
        }))
        
        alert.addAction(UIAlertAction(title: "Stats", style: .default, handler: { (action) in
            self.handleStats(path: self.pwd + "/" + item["name"]!)
        }))
        
        alert.addAction(UIAlertAction(title: "Move", style: .destructive, handler: { (action) in
            self.handleMove(from: self.pwd + "/" + item["name"]!, to: self.sidePWD)
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.handleDelete(path: self.pwd + "/" + item["name"]!)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.presenter!(alert, true, nil)
    }
    
    private func handleCopy(from: String, to: String) {
        do {
            try SSHSession?.channel.execute("cp -rf \"" + from + "\" \"" + to + "\"")
        } catch let error {
            print("error: \(error)")
        }
        
        executionListener!()
        handleAfterExecution();
    }
    
    private func handleMove(from: String, to: String) {
        do {
            try SSHSession?.channel.execute("mv -f \"" + from + "\" \"" + to + "\"")
        } catch let error {
            print("error: \(error)")
        }
        
        executionListener!()
        handleAfterExecution();
    }
    
    private func handleDelete(path: String) {
        do {
            try SSHSession?.channel.execute("rm -rf \"" + path + "\"")
        } catch let error {
            print("error: \(error)")
        }
        
        executionListener!()
        handleAfterExecution();
    }
    
    private func handleRun(path: String, args: String) {
        let run = SSHSession?.channel.execute("sh \"" + path + "\" " + args, error: nil, timeout: 5)
        print(run ?? "Run FFS")
        
        executionListener!()
        handleAfterExecution();
    }
    
    private func handleView(path: String) {
        do {
            let cat = try SSHSession?.channel.execute("cat \"" + path + "\"")
            
            let viewAlert = UIAlertController(title: "Viewing " + path, message: cat, preferredStyle: .alert)
            viewAlert.addAction(UIAlertAction(title: "Done", style: .default))
            
            self.presenter!(viewAlert, true, nil)
        } catch let error {
            print("error: \(error)")
        }
    }
    
    
    private func handleStats(path: String) {
        do {
            let cat = try SSHSession?.channel.execute("ls -alh \"" + path + "\"")
            
            let viewAlert = UIAlertController(title: "Stats " + path, message: cat, preferredStyle: .alert)
            viewAlert.addAction(UIAlertAction(title: "Done", style: .default))
            
            self.presenter!(viewAlert, true, nil)
        } catch let error {
            print("error: \(error)")
        }
    }
}
