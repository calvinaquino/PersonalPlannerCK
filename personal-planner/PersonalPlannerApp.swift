//
//  PersonalPlannerApp.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-06-22.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

@main
struct PersonalPlannerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//  @Environment(\.scenePhase) private var scenePhase
  
  @SceneBuilder var body: some Scene {
    WindowGroup {
      ContentView(tabIndex: 0)
    }
  }
}
