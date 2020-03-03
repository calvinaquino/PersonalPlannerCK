//
//  AppDelegate.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { authorized, error in
      DispatchQueue.main.async {
        if authorized {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    })
    
    return true
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
    let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo)
    if let notification = notification {
      if let recordID = notification.recordID {
        switch notification.queryNotificationReason {
        case .recordDeleted:
          Store.shared.deleteRecord(recordID)
          completionHandler(.noData)
        default:
          Cloud.handleCreatedOrUpdatedRecord(recordID) {
            completionHandler(.newData)
          }
        }
      }
    }
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Cloud.subscribeIfNeeded()
  }
  
}

