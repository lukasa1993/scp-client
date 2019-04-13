//
//  TailViewController.swift
//  SCP
//
//  Created by LD on 4/13/19.
//  Copyright © 2019 LD. All rights reserved.
//

import UIKit

class TailViewController: UIViewController, NMSSHChannelDelegate {
    var path:String = ""
    var session:NMSSHSession? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        session!.channel.delegate = self
        session!.channel.requestPty = true
        session!.channel.ptyTerminalType = .ansi
        do {
            try session!.channel.startShell()
            try session!.channel.write("tail -f " + path)
        } catch let error {
            print("error: \(error)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        session?.channel.closeShell()
    }
    
    func channel(_ channel: NMSSHChannel!, didReadData message: String!) {
        NSLog("message: " + message)
    }
    
    func channel(_ channel: NMSSHChannel!, didReadError error: String!) {
        NSLog("Error: " + error)
    }
    

}
