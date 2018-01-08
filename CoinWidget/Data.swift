//
//  Data.swift
//  CoinWidget
//
//  Created by Ty Schenk on 12/31/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import Foundation
import CoreData
import Alamofire

let defaults = UserDefaults(suiteName: "group.coinaudit.data")!

var favorites: [String] = []
var walletCoins: [NSManagedObject] = []
var widgetValue: String = ""
var walletValue: String = ""
var widgetPercent: String = ""
var themeValue: String = ""
var priceFormat: String = ""

// MARK: Check Network
class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

class CoreDataStack {
    
    static let sharedInstance = CoreDataStack()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let container = self.persistentContainer
        return container.viewContext
    }()
    
    fileprivate lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Wallet")
        container.loadPersistentStores() { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error: \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
}

func loadWallet() {
    let managedObjectContext = CoreDataStack.sharedInstance.managedObjectContext

    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WalletEntry")
    do {
        
        let fetchedCoin = try managedObjectContext.fetch(fetchRequest)
        
        // reset wallet array
        walletCoins.removeAll()
        
        // add newly fetched coins to wallet
        for object in fetchedCoin {
            walletCoins.append(object as! NSManagedObject)
        }
    } catch {
        fatalError("Failed to fetch coins: \(error)")
    }
}
