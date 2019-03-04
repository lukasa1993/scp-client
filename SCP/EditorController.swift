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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView?.text = data
        textView?.becomeFirstResponder()
    }
    
    @IBAction func save(sender: Any? = nil) {
        //        self.dismiss(animated: true, completion: nil)
        _ = navigationController?.popViewController(animated: true)
        cb?(textView!.text)
    }
}

