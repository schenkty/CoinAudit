//
//  AlertsViewController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 1/6/18.
//  Copyright © 2018 Ty Schenk. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner
import NotificationCenter
import UserNotifications
import GoogleMobileAds
import Localize_Swift
import SwiftTheme

class AlertsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var alertTableView: UITableView!
    @IBOutlet var alertsFailedLabel: UILabel!
    @IBOutlet var adView: GADBannerView!
    @IBOutlet var tableViewBottom: NSLayoutConstraint!
    
    var show = false
    let center = UNUserNotificationCenter.current()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.alertTableView.dataSource = self
        self.alertTableView.delegate = self
        self.alertTableView.rowHeight = UITableViewAutomaticDimension
        self.alertTableView.estimatedRowHeight = 44.0
        
        // MARK: Ad View
        if showAd == "Yes" {
            adView.adUnitID = GoogleAd.appID
            adView.rootViewController = self
            adView.load(GADRequest())
        } else if showAd == "No" {
        } else {
            adView.adUnitID = GoogleAd.appID
            adView.rootViewController = self
            adView.load(GADRequest())
        }
        
        // check for notificationID
        if notificationID != "" {
            show = true
        } else {
            show = false
        }
        
        if show {
            self.alertTableView.isHidden = false
            if alerts.count == 0 {
                self.updateData()
            }
        } else {
            self.alertTableView.isHidden = true
            SweetAlert().showAlert("Alerts Disabled".localized(), subTitle: "Please allow notifications in your device settings and restart CoinAudit".localized(), style: AlertStyle.none)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        updateTheme()

        if showAd == "Yes" {
            adView.isHidden = false
            tableViewBottom.constant = 50.0
        } else if showAd == "No" {
            adView.isHidden = true
            tableViewBottom.constant = 0.0
        } else {
            adView.isHidden = false
            tableViewBottom.constant = 50.0
        }
        
        if newAlertData == true {
            updateData()
            newAlertData = false
        } else {
            alertTableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if alerts.count != 0 && entries.count != 0 {
            return alerts.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // grab alert id
            let id = alerts[indexPath.row].id
            
            let cell = tableView.cellForRow(at: indexPath) as! AlertCell
            
            if Connectivity.isConnectedToInternet {
                // delete from server
                Alamofire.request("https://www.tyschenk.com/coinaudit/alerts/delete.php?id=\(id)")
                
                // delete from array
                alerts.remove(at: indexPath.row)
                
                // remove from table view
                self.alertTableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                SweetAlert().showAlert("No internet connection. Delete Failed".localized())
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // deselect row
        self.alertTableView.deselectRow(at: indexPath, animated: true)
        
        // push to add alert view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "addAlert") as! AddAlertViewController
        controller.new = false
        controller.alertID = alerts[indexPath.row].id
        controller.index = indexPath.row
        
        self.show(controller, sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "alertCell", for: indexPath) as! AlertCell
        
        if let selectionIndexPath = self.alertTableView.indexPathForSelectedRow {
            self.alertTableView.deselectRow(at: selectionIndexPath, animated: true)
        }
        
        let alert = alerts[indexPath.row]
        
        cell.nameLabel.text = alert.coin
        
        switch alert.action {
        case .Above:
            if alert.aboveCurrency == "USD" {
                cell.aboveLabel.text = "Value is above: $\(alert.above) \(alert.aboveCurrency)".localized()
            } else {
                cell.aboveLabel.text = "Value is above: \(alert.above) \(alert.aboveCurrency)".localized()
            }
            cell.belowLabel.isHidden = true
        case .Below:
            if alert.belowCurrency == "USD" {
                cell.belowLabel.text = "Value is below: $\(alert.below) \(alert.belowCurrency)".localized()
            } else {
                cell.belowLabel.text = "Value is below: \(alert.below) \(alert.belowCurrency)".localized()
            }
            cell.aboveLabel.isHidden = true
        case .Both:
            if alert.aboveCurrency == "USD" {
                cell.aboveLabel.text = "Value is above: $\(alert.above) \(alert.aboveCurrency)".localized()
            } else {
                cell.aboveLabel.text = "Value is above: \(alert.above) \(alert.aboveCurrency)".localized()
            }
            
            if alert.belowCurrency == "USD" {
                cell.belowLabel.text = "Value is below: $\(alert.below) \(alert.belowCurrency)".localized()
            } else {
                cell.belowLabel.text = "Value is below: \(alert.below) \(alert.belowCurrency)".localized()
            }
        default:
            cell.aboveLabel.text = "Alert failed to load".localized()
            cell.belowLabel.isHidden = true
        }
        
        // Theme Drawing code
        switch themeValue {
        case "dark":
            cell.nameLabel.textColor = UIColor.white
            cell.aboveLabel.textColor = UIColor.white
            cell.belowLabel.textColor = UIColor.white
            cell.backgroundColor = UIColor.black
        default:
            cell.nameLabel.textColor = UIColor.black
            cell.aboveLabel.textColor = UIColor.black
            cell.belowLabel.textColor = UIColor.black
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    @IBAction func newAlert(_ sender: UIBarButtonItem) {
        // push to add alert view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "addAlert") as! AddAlertViewController
        controller.new = true
        self.show(controller, sender: self)
    }
    
    @IBAction func updateData() {
        if Connectivity.isConnectedToInternet {
            // Provide using with loading spinner
            SwiftSpinner.show("Updating Alerts...".localized(), animated: true)
            
            // reset alert array
            alerts.removeAll()
            
            // get id of user
            guard let id = notificationID else { return }
            
            // Pull Alert Data
            Alamofire.request("https://www.tyschenk.com/coinaudit/alerts/get.php?id=\(id)").responseJSON { response in
                for alertJSON in (response.result.value as? [[String : AnyObject]])! {
                    if let alert = AlertEntry.init(json: alertJSON) {
                        // do something here
                        alerts.append(alert)
                    }
                }
                self.alertTableView.reloadData()
                SwiftSpinner.hide()
            }
        } else {
            SweetAlert().showAlert("No internet connection".localized())
        }
    }
    
    func updateTheme() {
        self.tabBarController?.tabBar.theme_barTintColor = ["#000", "#FFF"]
        self.tabBarController?.tabBar.theme_tintColor = ["#FFF", "#000"]
        self.view.theme_backgroundColor = ["#000", "#FFF"]
        self.alertTableView.theme_backgroundColor = ["#000", "#FFF"]
        self.navigationItem.leftBarButtonItem?.theme_tintColor = ["#FFF", "#000"]
        self.navigationItem.rightBarButtonItem?.theme_tintColor = ["#FFF", "#000"]
        self.navigationController?.navigationBar.theme_tintColor = ["#FFF", "#000"]
        self.navigationController?.navigationBar.theme_barTintColor = ["#000", "#FFF"]
        self.navigationController?.navigationBar.theme_tintColor = ["#FFF", "#000"]
        self.navigationController?.navigationBar.theme_titleTextAttributes = [[NSAttributedStringKey.foregroundColor.rawValue : UIColor.white], [NSAttributedStringKey.foregroundColor.rawValue : UIColor.black]]
        self.navigationController?.navigationBar.theme_largeTitleTextAttributes = [[NSAttributedStringKey.foregroundColor.rawValue : UIColor.white], [NSAttributedStringKey.foregroundColor.rawValue : UIColor.black]]
        alertsFailedLabel.theme_textColor = ["#FFF", "#000"]
    }

}
