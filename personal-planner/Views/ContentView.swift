//
//  ContentView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  
  @State var tabIndex: Int
  
  var body: some View {
    TabView(selection: self.$tabIndex) {
      ShoppingItemListView()
        .tabItem {
          Image(systemName: "cart")
          Text("Mercado")
      }.tag(0)
      TaskItemListView()
        .tabItem {
          Image(systemName: "checklist.checked")
          Text("Tarefas")
      }.tag(1)
      GoalItemListView()
        .tabItem {
          Image(systemName: "star")
          Text("Objetivos")
      }.tag(2)
    }
    .font(.headline)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(tabIndex: 0)
  }
}
