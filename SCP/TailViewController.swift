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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section(path)
        startTail()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keepAlive = false
    }
    
    
    func startTail() {
        DispatchQueue.global().async {
            do {
                let result = try self.session!.channel.execute("tail -n 4 " + self.path)
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
                    }
                    self.textIndex += 1
                }
                if self.keepAlive {
                    usleep(500)
                    self.startTail()
                }
            } catch let error {
                print("error: \(error)")
            }
        }
    }
    
    
}
