//
//  DetailViewController.swift
//  SCP
//
//  Created by LD on 4/6/18.
//  Copyright © 2018 LD. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController,UIPopoverPresentationControllerDelegate {
    
    @IBOutlet var leftTable: UITableView?
    @IBOutlet var rightTable: UITableView?
    
    var leftServer:SSHServerTableViewController? = nil
    var rightServer:SSHServerTableViewController? = nil
    
    func configureView() {        
        // Update the user interface for the detail item.
        if let detail = detailItem {
            do {
                let jsonDecoder = JSONDecoder()
                let server = try jsonDecoder.decode(SSHServer.self, from: detail.data(using: .utf8)!)
                
                leftServer = SSHServerTableViewController.init(nibName: nil, bundle: nil)
                rightServer = SSHServerTableViewController.init(nibName: nil, bundle: nil)
                
                leftServer?.isLeft = true
                
                leftServer?.tableView = leftTable
                rightServer?.tableView = rightTable
                
                leftServer?.SSHServer = server
                rightServer?.SSHServer = server
                
                leftServer?.presenter = self.presenter
                rightServer?.presenter = self.presenter
                
                leftServer?.sideListener = rightServer?.sideReceived
                rightServer?.sideListener = leftServer?.sideReceived
                
                leftServer?.executionListener = rightServer?.handleAfterExecution
                rightServer?.executionListener = leftServer?.handleAfterExecution
                
                leftServer?.start();
                rightServer?.start();
                
            } catch let error {
                print("error: \(error)")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        leftServer?.stop()
        rightServer?.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        
        for barButton in self.navigationItem.rightBarButtonItems! {
            if(barButton.tag == 1) {
                barButton.setIcon(icon: .googleMaterialDesign(.borderLeft), iconSize: 30, color: .blue)
            } else if(barButton.tag == 2) {
                barButton.setIcon(icon: .googleMaterialDesign(.borderVertical), iconSize: 30, color: .blue)
            } else if(barButton.tag == 3) {
                barButton.setIcon(icon: .googleMaterialDesign(.borderRight), iconSize: 30, color: .blue)
            }
        }
    }
    
    private func presenter(_ viewControllerToPresent: UIAlertController, animated flag: Bool, completion: (() -> Void)? = nil) {
        self.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showLeft(sender: UIBarButtonItem) {
        leftTable?.isHidden = false
        rightTable?.isHidden = true
    }
    
    @IBAction func showBoth(sender: UIBarButtonItem) {
        leftTable?.isHidden = false
        rightTable?.isHidden = false
    }
    
    @IBAction func showRigh(sender: UIBarButtonItem) {
        leftTable?.isHidden = true
        rightTable?.isHidden = false
    }
    
    var detailItem: String?
    
    
}

