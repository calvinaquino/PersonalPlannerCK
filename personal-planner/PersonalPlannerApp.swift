////
////  PersonalPlannerApp.swift
////  personal-planner
////
////  Created by Calvin De Aquino on 2020-06-22.
////  Copyright © 2020 Calvin Aquino. All rights reserved.
////
//
//import SwiftUI
//
//@main
//struct PersonalPlannerApp: App {
//  
//  @Environment(\.scenePhase) private var scenePhase
//  
//  func onAppStart() {
//    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { authorized, error in
//      DispatchQueue.main.async {
//        if authorized {
//          UIApplication.shared.registerForRemoteNotifications()
//          Cloud.subscribeIfNeeded()
//        }
//      }
//    })
//  }
//  
//  @SceneBuilder var body: some Scene {
//    WindowGroup {
//      ContentView(tabIndex: 0)
//        .onAppear {
//          onAppStart()
//        }
//    }
//    .onChange(of: scenePhase) { newScenePhase in
//      if newScenePhase == .background {
////        cache.empty()
//      }
//    }
//  }
//}
