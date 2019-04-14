//
//  TailViewController.swift
//  SCP
//
//  Created by LD on 4/13/19.
//  Copyright © 2019 LD. All rights reserved.
//

import UIKit
import Eureka

class TailViewController: FormViewController, Themeable  {
    var path:String = ""
    var session:NMSSHSession? = nil
    var textIndex = 0
    var keepAlive = true
    var textUnique: Set<String> = []
    var lineCount = 1
    var timeout = 500
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
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.cellSeparatorColor
        
        for cell in tableView.visibleCells {
            cell.apply(theme: currentTheme)
        }
        
        for row in form.allRows {
            row.baseCell.apply(theme: currentTheme)
            row.updateCell()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentTheme.statusBarStyle
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.apply(theme: currentTheme)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dark_mode = (UserDefaults.standard.object(forKey: "dark_mode") as? Bool) ?? false
        currentTheme  = dark_mode ? .dark : .light
        
        
        
        form +++ Section(header: path, footer: "kuku")
        startTail()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keepAlive = false
    }
    
    @IBAction func editTail(_ sender: UIBarButtonItem? = nil) {
        //get the Slider values from UserDefaults
        let defaultSliderValue = UserDefaults.standard.float(forKey: "sliderValue")
        
        //create the Alert message with extra return spaces
        let sliderAlert = UIAlertController(title: "Options", message: "Set Tail Options", preferredStyle: UIAlertController.Style.actionSheet)
        
        //create a Slider and fit within the extra message spaces
        //add the Slider to a Subview of the sliderAlert
        let slider = UISlider(frame:CGRect(x: 10, y: 100, width: 250, height: 80))
        slider.minimumValue = 1
        slider.maximumValue = 100
        slider.value = defaultSliderValue
        slider.isContinuous = true
        slider.tintColor = UIColor.cyan
        sliderAlert.view.addSubview(slider)
                
        //present the sliderAlert message
        self.present(sliderAlert, animated: true, completion: nil)
    }
    
    func startTail() {
        DispatchQueue.global().async {
            do {
                let result = try self.session!.channel.execute("tail -n \(self.lineCount) \(self.path)")
                let before = self.textUnique.count
                self.textUnique.insert(result)
                let after = self.textUnique.count
                if after > before {
                    DispatchQueue.main.async {
                        let tag = "text_" + String(self.textIndex)
                        self.form.last! <<< TextAreaRow(tag) {
                            $0.value = result
                            $0.textAreaMode = .readOnly
                            $0.cell.textView.contentOffset = .zero
                            }.cellUpdate { cell,row in
                                row.cell.textView.backgroundColor = self.currentTheme.backgroundColor
                                row.cell.textView.textColor = self.currentTheme.cellMainTextColor
                                row.cell.placeholderLabel?.textColor = self.currentTheme.cellDetailTextColor
                                cell.apply(theme: self.currentTheme)
                        }
                        
                        let formatter = DateFormatter()
                        formatter.dateStyle = .none
                        formatter.timeStyle = .short
                        self.form.last!.footer?.title = formatter.string(from: Date())
                        self.form.last!.reload()
                    }
                    self.textIndex += 1
                }
                if self.keepAlive {
                    usleep(useconds_t(self.timeout))
                    self.startTail()
                }
            } catch let error {
                print("error: \(error)")
            }
        }
    }
    
    
}
