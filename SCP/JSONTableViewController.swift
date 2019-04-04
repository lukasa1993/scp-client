//
//  JSONTableViewController.swift
//  SCP
//
//  Created by LD on 4/2/19.
//  Copyright © 2019 LD. All rights reserved.
//

import UIKit
import Eureka

extension JSON {
    mutating func appendIfArray(json:JSON){
        if var arr = self.array {
            arr.append(json)
            self = JSON(arr);
        }
    }
    
    mutating func appendIfDictionary(key:String, json:JSON){
        if var dict = self.dictionary {
            dict[key] = json;
            self = JSON(dict);
        }
    }
    
    mutating func append(key:String?, json:JSON) {
        if self.type == Type.array {
            self.appendIfArray(json: json)
        } else {
            self.appendIfDictionary(key: key!, json: json)
        }
    }
}

class JSONTableViewController: FormViewController, Themeable {
    
    var data:String = ""
    var cb:((String)->())? = nil
    
    private var json:JSON? = nil
    private var nextLayer = false
    
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
    
    @objc func save(sender: Any? = nil) {
        _ = navigationController!.popViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.cb?(self.json!.rawString()!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.save(sender:)))
        self.navigationItem.rightBarButtonItem = saveItem
        
        let dark_mode = (UserDefaults.standard.object(forKey: "dark_mode") as? Bool) ?? false
        currentTheme  = dark_mode ? .dark : .light
        
        if let dataFromString = data.data(using: .utf8, allowLossyConversion: false) {
            do {
                json = try JSON(data: dataFromString)
            } catch _ {
                print("cant parse json");
            }
        } else {
            print("Bad json");
        }
        
        if json == nil {
            return
        }
        
        form +++ Section()
        self.parseJSON(key: nil, json: json!)
    }
    
    func parseJSON(key:String?, json:JSON) {
        if json.type == Type.dictionary {
            if nextLayer == false {
                nextLayer = true
                self.parseDictionary(json: json)
            } else {
                self.handleButtonRow(key: key!, json: json)
            }
        } else if json.type == Type.array {
            if nextLayer == false {
                nextLayer = true
                self.parseArray(json: json)
            } else {
                self.handleButtonRow(key: key!, json: json)
            }            
        } else if json.type == Type.string {
            self.parseString(key:key!, json: json)
        } else if json.type == Type.number {
            self.parseNumber(key:key!, json: json)
        } else if json.type == Type.bool {
            self.parseBool(key:key!, json: json)
        }
    }
    
    func parseArray(json:JSON) {
        for (index,subJson):(String, JSON) in json {
            self.parseJSON(key: index, json: subJson)
        }
        
        self.addInsert()
    }
    
    func parseDictionary(json:JSON) {
        var keys = Array<String>()
        for (key,_):(String, JSON) in json {
            keys.append(key)
        }
        keys = keys.sorted{$0.compare($1, options: .caseInsensitive) == .orderedAscending }
        for key in keys {
            self.parseJSON(key:key, json: json[key])
        }
        
        self.addInsert()
    }
    
    func parseString(key:String, json:JSON) {
        if json.string!.count > 20 {
            self.lastSection()
                <<< LabelRow(key + "_labeltag") {
                    $0.title = key
                    }.cellUpdate { cell,row in
                        row.cell.textLabel?.textColor = self.currentTheme.cellMainTextColor
                }
                <<< TextAreaRow(key + "_textareatag") {
                    $0.value = json.string
                    self.addDelete(key: key, row: $0)
                    }.cellUpdate { cell,row in                        
                        row.cell.textView.backgroundColor = self.currentTheme.backgroundColor
                        row.cell.textView.textColor = self.currentTheme.cellMainTextColor
                        row.cell.placeholderLabel?.textColor = self.currentTheme.cellDetailTextColor
                        cell.apply(theme: self.currentTheme)
                    }.onChange { row in
                        self.updateJSON(key: key, value: JSON(row.value ?? ""))
            }
        } else {
            self.lastSection() <<< TextRow() {
                $0.title = key
                $0.value = json.string
                
                self.addDelete(key: key, row: $0)
                
                }.cellUpdate { cell,row in
                    row.cell.textLabel?.textColor = self.currentTheme.cellMainTextColor
                    row.cell.textField.textColor = self.currentTheme.cellMainTextColor
                    row.placeholderColor = self.currentTheme.cellDetailTextColor
                    cell.apply(theme: self.currentTheme)
                }.onChange { row in
                    self.updateJSON(key: key, value: JSON(row.value ?? ""))
            }
        }
    }
    
    func parseNumber(key:String, json:JSON) {
        self.lastSection() <<< DecimalRow() {
            $0.title = key
            $0.value = json.number!.doubleValue
            self.addDelete(key: key, row: $0)
            }.cellUpdate { cell,row in
                row.cell.textLabel?.textColor = self.currentTheme.cellMainTextColor
                row.cell.textField.textColor = self.currentTheme.cellMainTextColor
                row.placeholderColor = self.currentTheme.cellDetailTextColor
                cell.apply(theme: self.currentTheme)
            }.onChange { row in
                let val = row.value ?? 0
                self.updateJSON(key: key, value: JSON(val))
        }
    }
    
    func parseBool(key:String, json:JSON) {
        self.lastSection() <<< SwitchRow(key) {
            $0.title = key
            $0.value = json.bool
            self.addDelete(key: key, row: $0)
            }.cellUpdate { cell,row in
                row.cell.textLabel?.textColor = self.currentTheme.cellMainTextColor
                cell.apply(theme: self.currentTheme)
            }.onChange { row in
                self.updateJSON(key: key, value: JSON(row.value!))
        }
    }
    
    func handleButtonRow(key:String, json:JSON) {
        self.lastSection() <<< ButtonRow() {
            $0.title = key
            self.addDelete(key: key, row: $0)
            $0.presentationMode =  PresentationMode.show(
                controllerProvider: ControllerProvider.callback(builder: { () -> UIViewController in
                    return self.presentSubJSONEditor(key:key, json: json)
                }),
                onDismiss: nil)
            }.cellUpdate { cell,row in
                row.cell.textLabel?.textColor = self.currentTheme.cellMainTextColor
                cell.apply(theme: self.currentTheme)
        }
    }
    
    func updateJSON(key:String, value:JSON) {
        if self.json!.type == Type.array {
            let index:Int = Int(key)!
            self.json![index] = value
        } else {
            self.json![key] = value
        }
    }
    
    func presentSubJSONEditor(key:String, json:JSON) -> UIViewController {
        let editor = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "jsoneditortable") as! JSONTableViewController
        editor.data = json.rawString()!
        editor.cb = {(data:String) in
            if let dataFromString = data.data(using: .utf8, allowLossyConversion: false) {
                do {
                    let changedJSON = try JSON(data: dataFromString)
                    if self.json![key].exists() {
                        self.json![key] = changedJSON
                    } else {
                        self.json!.append(key: key, json: changedJSON)
                    }
                    print(self.json!.rawString()!)
                    self.save()
                } catch _ {
                    print("cant parse json");
                }
            } else {
                print("Bad json");
            }
        }
        editor.title = key;
        
        return editor
    }
    
    func lastSection() -> Section {
        var section = self.form.last!
        
        if section.tag == "inset_section" {
            section = self.form.allSections[self.form.allSections.count - 2]
        }
        
        return section
    }
    
    func addInsert() {
        form +++ Section("Insert New Element") {
            $0.tag = "inset_section"
            }
            <<< TextRow("new_element_key") {
                $0.title = "Key"
                $0.disabled = self.json!.type == Type.array ? true : false
                }.cellUpdate { cell,row in
                    row.cell.textLabel?.textColor = self.currentTheme.cellMainTextColor
                    row.cell.textField.textColor = self.currentTheme.cellMainTextColor
                    row.placeholderColor = self.currentTheme.cellDetailTextColor
                    cell.apply(theme: self.currentTheme)
            }
            <<< SegmentedRow<String>("new_element_type") {
                $0.options = ["Object", "Array", "String", "Number", "Boolean"]
                $0.value = "Object"
            }
            <<< ButtonRow() {
                $0.title = "Insert"
                $0.onCellSelection { cell, row in
                    let key  = (self.form.rowBy(tag: "new_element_key") as! TextRow).value ?? String(self.json!.count)
                    let type = (self.form.rowBy(tag: "new_element_type") as! SegmentedRow<String>).value!
                    let typeMap:JSON = [
                        "Object": JSON().dictionary!,
                        "Array": JSON().arrayValue,
                        "String": "",
                        "Number": 0.0,
                        "Boolean": true
                        ]
                    let elem = typeMap[type]
                    
                    self.json!.append(key: key, json: elem)
                    print(self.json!.rawString()!)
                    self.parseJSON(key: key, json: elem)
                }
                }.cellUpdate { cell,row in
                    row.cell.textLabel?.textColor = self.currentTheme.cellMainTextColor
                    cell.apply(theme: self.currentTheme)
        }
    }
    
    func addDelete(key:String, row:BaseRow) {
        let deleteAction = SwipeAction(
            style: .destructive,
            title: "Delete",
            handler: { (action, row, completionHandler) in
                var trimedJSON = JSON()
                for (dKey,subJson):(String, JSON) in self.json! {
                    if dKey != key {
                        trimedJSON[dKey] = subJson
                    }
                }
                self.json = trimedJSON
                
                if let labelRow = self.form.rowBy(tag: key + "_labeltag") {
                    labelRow.section?.remove(at: labelRow.indexPath!.row)
                }
                completionHandler?(true)
        })
        deleteAction.image = UIImage(named: "icon-trash")
        
        row.trailingSwipe.actions = [deleteAction]
        row.trailingSwipe.performsFirstActionWithFullSwipe = true
    }
}
