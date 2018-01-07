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

class AlertsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var alertTableView: UITableView!
    @IBOutlet var alertsFailedLabel: UILabel!
    
    var show = false
    let center = UNUserNotificationCenter.current()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.alertTableView.dataSource = self
        self.alertTableView.delegate = self
        self.alertTableView.rowHeight = UITableViewAutomaticDimension
        self.alertTableView.estimatedRowHeight = 44.0
        
        // Do any additional setup after loading the view.
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
            self.showAlert(title: "Alerts Disabled", message: "Please allow notifications in your device settings and restart CoinAudit", style: .alert)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        updateTheme()
        
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
            
                print("Deleted: \(cell.nameLabel.text!) from alerts")
            } else {
                showAlert(title: "No internet connection. Delete Failed")
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
        
        print("alert at id: \(alerts[indexPath.row].id)")
        
        switch alert.action {
        case .Above:
            cell.aboveLabel.text = "Value is above: \(alert.above) \(alert.aboveCurrency)"
            cell.belowLabel.isHidden = true
        case .Below:
            cell.belowLabel.text = "Value is below: \(alert.below) \(alert.belowCurrency)"
            cell.aboveLabel.isHidden = true
        case .Both:
            cell.aboveLabel.text = "Value is above: \(alert.above) \(alert.aboveCurrency)"
            cell.belowLabel.text = "Value is below: \(alert.below) \(alert.belowCurrency)"
        default:
            cell.aboveLabel.text = "Alert failed to load"
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
            SwiftSpinner.show("Updating Alerts...", animated: true)
            
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
            showAlert(title: "No internet connection")
        }
    }
    
    func updateTheme() {
        switch themeValue {
        case "dark":
            self.tabBarController?.tabBar.barTintColor = UIColor.black
            self.tabBarController?.tabBar.tintColor = UIColor.white
            self.view.backgroundColor = UIColor.black
            self.alertTableView.backgroundColor = UIColor.black
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.barTintColor = UIColor.black
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
            alertsFailedLabel.textColor = UIColor.white
        default:
            self.tabBarController?.tabBar.barTintColor = UIColor.white
            self.tabBarController?.tabBar.tintColor = UIColor.black
            self.view.backgroundColor = UIColor.white
            self.alertTableView.backgroundColor = UIColor.white
            self.navigationController?.navigationBar.tintColor = UIColor.black
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
            alertsFailedLabel.textColor = UIColor.black
        }
    }

}
