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
        
        self.lineCount = UserDefaults.standard.integer(forKey: "tail_linecount")
        self.timeout = UserDefaults.standard.integer(forKey: "tail_timeout")
        
        if self.lineCount == 0 {
            self.lineCount = 1
        }
        
        if self.timeout == 0 {
            self.timeout = 500
        }
        
        form +++ Section(header: path, footer: "…")
        startTail()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keepAlive = false
    }
    
    @IBAction func editTail(_ sender: UIBarButtonItem? = nil) {
        let dark_mode = (UserDefaults.standard.object(forKey: "dark_mode") as? Bool) ?? false
        
        let alertController = UIAlertController(title: "Add New Name", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.text = String(self.lineCount)
            textField.becomeFirstResponder()
            textField.backgroundColor = nil
            textField.textColor = .black
            textField.placeholder = "Line Number"
            textField.clearButtonMode = .whileEditing
            textField.autocapitalizationType = .none
            textField.keyboardAppearance =  dark_mode ? .dark : .light
            textField.keyboardType = .numberPad
            textField.returnKeyType = .continue
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.text = String(self.timeout)
            textField.backgroundColor = nil
            textField.textColor = .black
            textField.placeholder = "Timeout"
            textField.clearsOnBeginEditing = false
            textField.autocapitalizationType = .none
            textField.keyboardAppearance =  dark_mode ? .dark : .light
            textField.keyboardType = .numberPad
            textField.isSecureTextEntry = false
            textField.returnKeyType = .done
        }
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            let secondTextField = alertController.textFields![1] as UITextField
            
            self.lineCount = Int(firstTextField.text!)!
            self.timeout = Int(secondTextField.text!)!
            UserDefaults.standard.set(self.lineCount, forKey: "tail_linecount")
            UserDefaults.standard.set(self.timeout, forKey: "tail_timeout")
        })
        alertController.addAction(saveAction)

        //present the sliderAlert message
        self.present(alertController, animated: true, completion: nil)
        
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
                            $0.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 110)
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(self.timeout), execute: {
                        self.startTail()
                    })
                }
            } catch let error {
                print("error: \(error)")
            }
        }
    }
    
    
}
