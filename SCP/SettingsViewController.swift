//
//  SettingsViewController.swift
//  SCP
//
//  Created by LD on 3/29/19.
//  Copyright © 2019 LD. All rights reserved.
//

import Eureka
import PasscodeLock
import StoreKit
import SwiftyStoreKit

class SettingsViewController: FormViewController, Themeable {
    let premiumId = "com.picktek.sscpclient.premium_access"
    var premiumPurchased = false
    
    var currentTheme: Theme = .light {
        didSet {
            apply(theme: currentTheme)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let dark_mode     = (UserDefaults.standard.object(forKey: "dark_mode") as? Bool) ?? false
        let folder_first  = (UserDefaults.standard.object(forKey: "folder_first") as? Bool) ?? false
        let hidden        = (UserDefaults.standard.object(forKey: "show_hidden_files") as? Bool) ?? false
        let repo          = UserDefaultsPasscodeRepository()
        let configuration = PasscodeLockConfiguration(repository: repo)
        var skipBioChange = false
        
        currentTheme  = dark_mode ? .dark : .light
        
        self.restorePurchases()
        //        self.getInfo(self.premiumId)
        
        form +++ Section("General")
            <<< SwitchRow("show_hidden") { row in
                row.title = "Show Hidden Files"
                row.value = hidden
                }.onChange { row in
                    UserDefaults.standard.set(row.value, forKey: "show_hidden_files")
                    UserDefaults.standard.synchronize()
            }
            <<< SwitchRow("folder_first") { row in
                row.title = "Sort Folders First"
                row.value = folder_first
                }.onChange { row in
                    UserDefaults.standard.set(row.value, forKey: "folder_first")
                    UserDefaults.standard.synchronize()
            }
            +++ Section("Security")
            <<< SwitchRow("bio_auth") { row in
                row.title = "Biometric Auth"
                row.value = repo.hasPasscode
                }.onChange { row in
                    if(skipBioChange) {
                        skipBioChange = false
                        return
                    }
                    let isDeleting = !row.value!
                    var wasSuccsess = true
                    let passcodeViewController = PasscodeLockViewController(state: row.value! ? .setPasscode : .removePasscode , configuration: configuration)
                    passcodeViewController.successCallback = { lock in
                        wasSuccsess = true
                        if(isDeleting) {
                            lock.repository.deletePasscode()
                        }
                        if(row.value != lock.repository.hasPasscode) {
                            skipBioChange = true
                        }
                        row.value = lock.repository.hasPasscode
                        row.updateCell()
                        self.apply(theme: self.currentTheme)
                    }
                    passcodeViewController.dismissCompletionCallback = {
                        if(wasSuccsess) {
                            wasSuccsess = false
                            return
                        }
                        if(row.value != repo.hasPasscode) {
                            skipBioChange = true
                        }
                        row.value = repo.hasPasscode
                        row.updateCell()
                        self.apply(theme: self.currentTheme)
                    }
                    self.present(passcodeViewController, animated: true, completion: nil)
            }
            +++ Section(header: "Premium", footer: "This is more of a donation than a pay-wall since code is open-source.")
            <<< SwitchRow("dark_mode") { row in
                row.title = "Dark Mode"
                row.value = dark_mode
                row.disabled = true
                }.onChange { row in
                    if(self.premiumPurchased) {
                        UserDefaults.standard.set(row.value, forKey: "dark_mode")
                        UserDefaults.standard.synchronize()
                        let swtch = self.form.rowBy(tag: "dark_mode") as! SwitchRow
                        self.toggleDarkMode(swtch.cell.switchControl)
                    } else {
                        self.purchase(self.premiumId, atomically: true)                        
                    }
                    
            }
            +++ Section(header: "Support", footer: "Please include version : " + self.version() + " in your ticket")
            <<< ButtonRow() {
                $0.title = "Get HELP!"
                $0.onCellSelection { cell, row in
                    guard let url = URL(string: "https://github.com/lukasa1993/scp-client/issues") else { return }
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
            +++ Section(header: "Beta", footer: "Public TestFlight is for early access if you want to have sneak peak on new features")
            <<< ButtonRow() {
                $0.title = "Join TestFlight"
                $0.onCellSelection { cell, row in
                    guard let url = URL(string: "https://testflight.apple.com/join/ZqAD0ONr") else { return }
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.apply(theme: currentTheme)
    }
    
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }
    
    @objc private func toggleDarkMode(_ sender: UISwitch) {
        // Circular
        let center = sender.superview?.convert(sender.center, to: nil) ?? .zero
        CircularReveal.animate(from: center) { _ in
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
        currentTheme = sender.isOn ? .dark : .light
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
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentTheme.statusBarStyle
    }
    
    func purchase(_ purchase: String, atomically: Bool) {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(purchase, atomically: atomically) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            if case .success(let purchase) = result {
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                }
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            if let alert = self.alertForPurchaseResult(result) {
                self.showAlert(alert)
            }
        }
    }
    
    func restorePurchases() {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            for purchase in results.restoredPurchases {
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                } else if purchase.needsFinishTransaction {
                    // Deliver content from server, then:
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            let alert = self.alertForRestorePurchases(results)
            (self.form.rowBy(tag: "dark_mode") as! SwitchRow).cell.switchControl.isEnabled = true
            print(alert)
            //            self.showAlert(alert)
        }
    }
    
    func getInfo(_ purchase: String) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([purchase]) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            //            self.showAlert(self.alertForProductRetrievalInfo(result))
            (self.form.rowBy(tag: "dark_mode") as! SwitchRow).cell.switchControl.isEnabled = true
        }
    }
    
}

// MARK: User facing alerts
extension SettingsViewController {
    
    func alertWithTitle(_ title: String, message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    
    func showAlert(_ alert: UIAlertController) {
        guard self.presentedViewController != nil else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func alertForProductRetrievalInfo(_ result: RetrieveResults) -> UIAlertController {
        
        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            return alertWithTitle(product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
        } else if let invalidProductId = result.invalidProductIDs.first {
            return alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)")
        } else {
            let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
            return alertWithTitle("Could not retrieve product info", message: errorString)
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController? {
        switch result {
        case .success(let purchase):
            premiumPurchased = true
            let swtch = self.form.rowBy(tag: "dark_mode") as! SwitchRow
            self.toggleDarkMode(swtch.cell.switchControl)
            UserDefaults.standard.set(swtch.cell.switchControl.isOn, forKey: "dark_mode")
            UserDefaults.standard.synchronize()
            print("Purchase Success: \(purchase.productId)")
            return nil
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error.code {
            case .unknown: return alertWithTitle("Purchase failed", message: error.localizedDescription)
            case .clientInvalid: // client is not allowed to issue the request, etc.
                return alertWithTitle("Purchase failed", message: "Not allowed to make the payment")
            case .paymentCancelled: // user cancelled the request, etc.
                return nil
            case .paymentInvalid: // purchase identifier was invalid, etc.
                return alertWithTitle("Purchase failed", message: "The purchase identifier was invalid")
            case .paymentNotAllowed: // this device is not allowed to make the payment
                return alertWithTitle("Purchase failed", message: "The device is not allowed to make the payment")
            case .storeProductNotAvailable: // Product is not available in the current storefront
                return alertWithTitle("Purchase failed", message: "The product is not available in the current storefront")
            case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                return alertWithTitle("Purchase failed", message: "Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                return alertWithTitle("Purchase failed", message: "Could not connect to the network")
            case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                return alertWithTitle("Purchase failed", message: "Cloud service was revoked")
            default:
                return alertWithTitle("Purchase failed", message: (error as NSError).localizedDescription)
            }
        }
    }
    
    func alertForRestorePurchases(_ results: RestoreResults) -> UIAlertController {
        
        if results.restoreFailedPurchases.count > 0 {
            print("Restore Failed: \(results.restoreFailedPurchases)")
            return alertWithTitle("Restore failed", message: "Unknown error. Please contact support")
        } else if results.restoredPurchases.count > 0 {
            premiumPurchased = true
            print("Restore Success: \(results.restoredPurchases)")
            return alertWithTitle("Purchases Restored", message: "All purchases have been restored")
        } else {
            print("Nothing to Restore")
            return alertWithTitle("Nothing to restore", message: "No previous purchases were found")
        }
    }
    
    func alertForVerifyReceipt(_ result: VerifyReceiptResult) -> UIAlertController {
        
        switch result {
        case .success(let receipt):
            print("Verify receipt Success: \(receipt)")
            return alertWithTitle("Receipt verified", message: "Receipt verified remotely")
        case .error(let error):
            print("Verify receipt Failed: \(error)")
            switch error {
            case .noReceiptData:
                return alertWithTitle("Receipt verification", message: "No receipt data. Try again.")
            case .networkError(let error):
                return alertWithTitle("Receipt verification", message: "Network error while verifying receipt: \(error)")
            default:
                return alertWithTitle("Receipt verification", message: "Receipt verification failed: \(error)")
            }
        }
    }
    
    func alertForVerifySubscriptions(_ result: VerifySubscriptionResult, productIds: Set<String>) -> UIAlertController {
        
        switch result {
        case .purchased(let expiryDate, let items):
            print("\(productIds) is valid until \(expiryDate)\n\(items)\n")
            return alertWithTitle("Product is purchased", message: "Product is valid until \(expiryDate)")
        case .expired(let expiryDate, let items):
            print("\(productIds) is expired since \(expiryDate)\n\(items)\n")
            return alertWithTitle("Product expired", message: "Product is expired since \(expiryDate)")
        case .notPurchased:
            print("\(productIds) has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
    
    func alertForVerifyPurchase(_ result: VerifyPurchaseResult, productId: String) -> UIAlertController {
        
        switch result {
        case .purchased:
            print("\(productId) is purchased")
            return alertWithTitle("Product is purchased", message: "Product will not expire")
        case .notPurchased:
            print("\(productId) has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
}
