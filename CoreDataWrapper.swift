//
//  CoreDataWrapper.swift
//  GO
//
//  Created by Rupesh on 11/15/17.
//  Copyright © 2017 Ileaf Solutions. All rights reserved.
//

import Foundation
import CoreData

class CoreDataWrapper: NSObject {
    
    static let shared = CoreDataWrapper()
    var appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let moc: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchArray:[User] = []
    
    /// Save user details to Data base
    ///
    /// - Parameter userData: user details Model
    func saveUserData(userData:NSDictionary) {
        let user     = NSEntityDescription.insertNewObject(forEntityName: "User",into:moc) as! User
        let settings = NSEntityDescription.insertNewObject(forEntityName: "Settings",into:moc) as! Settings
        let userDetails:NSDictionary  = userData[USER] as! NSDictionary
        let userProfile:NSDictionary  = userDetails[PROFILE] as! NSDictionary
        let settingsDict:NSDictionary = userDetails [NOTIFICATION_SETTINGS] as! NSDictionary
        
        user.firstName   = userProfile[FIRST_NAME] as? String
        user.lastName    = userProfile[LAST_NAME] as? String
        user.email       = userDetails[EMAIL] as? String
        user.city        = userProfile[CITY] as? String
        user.country     = userProfile[COUNTRY] as? String
        user.latitude    = userProfile[LATITTUDE] as? String
        user.longitude   = userProfile[LATITTUDE] as? String
        user.state       = userProfile[STATE] as? String
        user.address     = userProfile[ADDRESS] as? String
        user.name        = userDetails[NAME] as? String
        user.dob         = userProfile[DATE_OF_BIRTH] as? String
        user.phone       = userProfile[PHONE] as? String
        user.userId      = (userProfile[USER_ID] as? Int16)!
        user.gender      = (userProfile[GENDER] as? Int16)!
        user.token       = userData[TOKEN] as? String

        settings.appNotifictions          = settingsDict[APP_NOTIFICATION] as! Bool
        settings.tipsNotifications        = settingsDict[TIPS_NOTIFICATION] as! Bool
        settings.suggestionNotifications  = settingsDict[APP_NOTIFICATION] as! Bool
        settings.notifictions             = settingsDict[APP_NOTIFICATION] as! Bool
        user.userSettings                 = settings
        
        if let token = userData[TOKEN] as? String  {
            /// Set User Token to User Default Storage
            UserDefaultsManager.authToken  = token
        }
        /// Once loggin
        UserDefaultsManager.isLoggedIn      = true
        UserDefaultsManager.isFirstLoggedIn = true
        UserDefaultsManager.userId = userProfile[USER_ID] as? Int
        var _ : NSError? = nil
        appDelegate.saveContext()
    }
    /// Save User Settings
    ///
    /// - Parameters:
    ///   - appNotification: App Notification ON or OFF
    ///   - tipsNotification: Tips Notification ON or OFF
    ///   - destinationNotification: Destination Notification ON or OFF
    func saveUserSettings(notifications:Bool, appNotification:Bool, tipsNotification:Bool, destinationNotification:Bool,userID:Int16) {
        let settings = NSEntityDescription.insertNewObject(forEntityName: "Settings",into:moc) as! Settings
        settings.appNotifictions          = appNotification
        settings.tipsNotifications        = tipsNotification
        settings.suggestionNotifications  = destinationNotification
        settings.notifictions             = notifications

        let userFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        userFetch.predicate = NSPredicate(format: "userId == %d", userID)
        
        do {
            let fetchedUser = try moc.fetch(userFetch) as! [User]
            print(fetchedUser)
            let user = fetchedUser.last
            user?.userSettings = settings
        } catch {
            fatalError("Failed to fetch user: \(error)")
        }
        
                var _ : NSError?  = nil
                appDelegate.saveContext()
    }
    /// User data fetch from Data base
    ///
    /// - Returns: fetch result array
    func fetchData() -> [User]{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            let results      = try context.fetch(fetchRequest)
            let  dateCreated = results as! [User]
            for fetchResult in dateCreated {
                print(fetchResult)
                fetchArray.append(fetchResult)
            }
        }catch let err as NSError {
            print(err.debugDescription)
        }
        return fetchArray
    }
    
    /// Save User Location
    ///
    /// - Parameters:
    ///   - address: current address
    ///   - city: current city
    ///   - state: current state
    ///   - country: current country
    ///   - lat: current latitude
    ///   - long: current longitude
    ///   - userID: current user Id
    func saveUserLocation(address: String, city: String, state: String, country: String, lat: Double, long: Double,userID:Int) {
       
        let userFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        userFetch.predicate = NSPredicate(format: "userId == %d", userID)
        
        do {
            let fetchedUser = try moc.fetch(userFetch) as! [User]
            print(fetchedUser)
            let user = fetchedUser.last
            user?.address   = address
            user?.city      = city
            user?.state     = state
            user?.country   = country
            user?.latitude  = String(lat)
            user?.longitude = String(long)
        } catch {
            fatalError("Failed to fetch user: \(error)")
        }
        
        var _ : NSError?  = nil
        appDelegate.saveContext()
    }
}

