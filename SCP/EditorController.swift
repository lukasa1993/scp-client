//
//  DetailViewController.swift
//  SCP
//
//  Created by LD on 4/6/18.
//  Copyright © 2018 LD. All rights reserved.
//

import UIKit

class EditorConroller: UIViewController, Themeable {
    
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
        
        configureKeyboardNotifications()
        
        textView?.text = data
        textView?.becomeFirstResponder()
    }
    
    @IBAction func save(sender: Any? = nil) {
        //        self.dismiss(animated: true, completion: nil)
        _ = navigationController?.popViewController(animated: true)
        cb?(textView!.text)
    }
    
    
    func configureKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(aNotification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(aNotification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWasShown(aNotification:NSNotification) {
        let info = aNotification.userInfo
        let infoNSValue = info![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let kbSize = infoNSValue.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 6*kbSize.height, right: 0.0)
        textView!.contentInset = contentInsets
        textView!.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillBeHidden(aNotification:NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        textView!.contentInset = contentInsets
        textView!.scrollIndicatorInsets = contentInsets
    }
}

