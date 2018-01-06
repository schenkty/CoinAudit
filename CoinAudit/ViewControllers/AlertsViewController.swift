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

class AlertsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var alertTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateTheme()
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
            // Action to delete data
            alerts.remove(at: indexPath.row)
            
            let cell = tableView.cellForRow(at: indexPath) as! AlertTableViewCell
            
            print("Deleted: \(cell.nameLabel.text!) from alerts")
            
            self.alertTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "feedDetails") as! CoinsDetailsViewController
//        favorites = favorites.sorted()
//        controller.id = favorites[indexPath.row]
//        self.show(controller, sender: self)
//
        print("cell selected: \(alerts[indexPath.row].coin)")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "alertCell", for: indexPath) as! AlertTableViewCell
        
        
        return cell
    }
    
    func updateData() {
        // Provide using with loading spinner
        SwiftSpinner.show(duration: 1.5, title: "Downloading Data...", animated: true)
        
        if Connectivity.isConnectedToInternet {
            // Pull Coin Data
            Alamofire.request("https://www.tyschenk.com/coinaudit/alerts/get.php").responseJSON { response in
                for alertJSON in (response.result.value as? [[String : AnyObject]])! {
                    if let alert = AlertEntry.init(json: alertJSON) {
                        // do something here
                        alerts.append(alert)
                    }
                }
                
                self.alertTableView.reloadData()
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
        }
    }

}
