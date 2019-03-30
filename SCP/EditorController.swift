//
//  DetailViewController.swift
//  SCP
//
//  Created by LD on 4/6/18.
//  Copyright © 2018 LD. All rights reserved.
//

import UIKit

class EditorConroller: UIViewController {
    
    var data:String = ""
    var cb:((String)->())? = nil
    @IBOutlet var textView: UITextView?
    
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
        
        view?.backgroundColor = theme.backgroundColor
        textView?.backgroundColor = theme.backgroundColor
        textView?.textColor = theme.cellMainTextColor
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentTheme.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let dark_mode = (UserDefaults.standard.object(forKey: "dark_mode") as? Bool) ?? false
        currentTheme  = dark_mode ? .dark : .light
        
        textView?.text = data
        textView?.becomeFirstResponder()
    }
    
    @IBAction func save(sender: Any? = nil) {
        //        self.dismiss(animated: true, completion: nil)
        _ = navigationController?.popViewController(animated: true)
        cb?(textView!.text)
    }
}

