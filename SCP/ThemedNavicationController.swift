//
//  PasscodeViewController.swift
//  SCP
//
//  Created by L on 01.07.22.
//  Copyright © 2022 LD. All rights reserved.
//

class ThemedNavicationController: UINavigationController, Themeable {
    
    var currentTheme: Theme = .light {
        didSet {
            apply(theme: currentTheme)
        }
    }
    
    func apply(theme: Theme) {
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentTheme.statusBarStyle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let dark_mode = (UserDefaults.standard.object(forKey: "dark_mode") as? Bool) ?? false
        currentTheme  = dark_mode ? .dark : .light
    }
}
