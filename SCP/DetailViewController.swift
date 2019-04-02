//
//  DetailViewController.swift
//  SCP
//
//  Created by LD on 4/6/18.
//  Copyright © 2018 LD. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet var leftTable: UITableView?
    @IBOutlet var rightTable: UITableView?
    
    var editorSegue: Bool = false
    
    var leftServer: SSHServerTableViewController? = nil
    var rightServer: SSHServerTableViewController? = nil
    
    var inactiveTimer: Timer?
    
    func configureView() {
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive),  name: UIApplication.didBecomeActiveNotification,  object: nil)
        
        if let viewState = UserDefaults.standard.object(forKey: detailItemUUID + "_selected_view") as? Int {
            DispatchQueue.main.async {
                if (viewState == 1) {
                    self.showLeft()
                } else if (viewState == 2) {
                    self.showBoth()
                } else if (viewState == 3) {
                    self.showRigh()
                }
            }
        }
        
        if let detail = detailItem {
            do {
                let jsonDecoder = JSONDecoder()
                let server = try jsonDecoder.decode(SSHServer.self, from: detail.data(using: .utf8)!)
                
                self.title = "Connecting…"
                
                leftServer = SSHServerTableViewController.init(nibName: nil, bundle: nil)
                rightServer = SSHServerTableViewController.init(nibName: nil, bundle: nil)
                
                leftServer?.isLeft = true
                rightServer?.isLeft = false
                
                leftServer?.tableView = leftTable
                rightServer?.tableView = rightTable
                
                leftServer?.SSHServer = server
                rightServer?.SSHServer = server
                
                leftServer?.presenter = self.presenter
                rightServer?.presenter = self.presenter
                
                leftServer?.performParentSegue = self.performSegue
                rightServer?.performParentSegue = self.performSegue
                
                leftServer?.exit = self.exit
                rightServer?.exit = self.exit
                
                leftServer?.sideListener = rightServer?.sideReceived
                rightServer?.sideListener = leftServer?.sideReceived
                
                leftServer?.executionListener = rightServer?.handleAfterExecution
                rightServer?.executionListener = leftServer?.handleAfterExecution
                
                leftServer?.serverUUID = detailItemUUID
                rightServer?.serverUUID = detailItemUUID
                
                leftServer?.start();
                rightServer?.start();
                
                DispatchQueue.global().async {
                    while (self.leftServer?.checkConnecting())! || (self.rightServer?.checkConnecting())! {
                        usleep(100)
                    }
                    DispatchQueue.main.async {
                        self.title = server.name
                    }
                }
                
            } catch let error {
                print("error: \(error)")
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let dark_mode = (UserDefaults.standard.object(forKey: "dark_mode") as? Bool) ?? false
        currentTheme  = dark_mode ? .dark : .light
        
        self.view.backgroundColor = currentTheme.backgroundColor
    }
    
    var currentTheme: Theme = .light {
        didSet {
            apply(theme: currentTheme)
        }
    }
    
    func apply(theme: Theme) {
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = theme.navigationBarColor
        navigationBar?.titleTextAttributes = [.foregroundColor: theme.navigationTextColor]
        
        tabBarController?.tabBar.barTintColor = theme.navigationBarColor
        
        leftTable!.backgroundColor = theme.backgroundColor
        leftTable!.separatorColor = theme.cellSeparatorColor
        
        for cell in leftTable!.visibleCells {
            cell.apply(theme: currentTheme)
        }
        
        rightTable!.backgroundColor = theme.backgroundColor
        rightTable!.separatorColor = theme.cellSeparatorColor
        
        for cell in rightTable!.visibleCells {
            cell.apply(theme: currentTheme)
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentTheme.statusBarStyle
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !editorSegue {
            leftServer?.stop()
            rightServer?.stop()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.configureView()
        }
        
        for barButton in self.navigationItem.rightBarButtonItems! {
            if (barButton.tag == 1) {
                barButton.setIcon(icon: .googleMaterialDesign(.borderLeft), iconSize: 30, color: .blue)
            } else if (barButton.tag == 2) {
                barButton.setIcon(icon: .googleMaterialDesign(.borderVertical), iconSize: 30, color: .blue)
            } else if (barButton.tag == 3) {
                barButton.setIcon(icon: .googleMaterialDesign(.borderRight), iconSize: 30, color: .blue)
            }
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissOnDone))
        editorSegue = false
    }
    
    @objc func willResignActive(_ notification: Notification) {
        inactiveTimer = Timer.scheduledTimer(timeInterval: 60 * 3, target: self, selector: #selector(self.exit), userInfo: nil, repeats: true)
    }
    
    @objc func didBecomeActive(_ notification: Notification) {
        inactiveTimer?.invalidate()
    }
    
    @objc func dismissOnDone() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func exit() {
        DispatchQueue.global().async {
            while (self.leftServer?.checkConnecting())! || (self.rightServer?.checkConnecting())! {
                usleep(100)
            }
            self.leftServer?.stop()
            self.rightServer?.stop()
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editor" {
            editorSegue = true
            let controller = segue.destination as! EditorConroller
            do {
                let payload = sender as! (tempFile:NSURL, cb:((String)->()))
                
                let tempFile = payload.tempFile
                controller.title = tempFile.lastPathComponent
                controller.data  = try String(contentsOf: tempFile.absoluteURL!, encoding: .utf8)
                controller.cb = payload.cb
            }
            catch let error {
                print("error: \(error)")
                controller.data = "Download Failed…"
            }
            
        } else if segue.identifier == "json_editor" {
            editorSegue = true
            let controller = segue.destination as! JSONTableViewController
            do {
                let payload = sender as! (tempFile:NSURL, cb:((String)->()))
                
                let tempFile = payload.tempFile
                controller.title = tempFile.lastPathComponent
                controller.data  = try String(contentsOf: tempFile.absoluteURL!, encoding: .utf8)
                controller.cb = payload.cb
            }
            catch let error {
                print("error: \(error)")
                controller.data = "Download Failed…"
            }
        }
    }
    
    @IBAction func showLeft(sender: UIBarButtonItem? = nil) {
        leftTable?.isHidden = false
        rightTable?.isHidden = true
        
        UserDefaults.standard.set(1, forKey: detailItemUUID + "_selected_view")
    }
    
    @IBAction func showBoth(sender: UIBarButtonItem? = nil) {
        leftTable?.isHidden = false
        rightTable?.isHidden = false
        UserDefaults.standard.set(2, forKey: detailItemUUID + "_selected_view")
    }
    
    @IBAction func showRigh(sender: UIBarButtonItem? = nil) {
        leftTable?.isHidden = true
        rightTable?.isHidden = false
        UserDefaults.standard.set(3, forKey: detailItemUUID + "_selected_view")
    }
    
    var detailItem: String?
    var detailItemUUID: String = ""
    
    
}

