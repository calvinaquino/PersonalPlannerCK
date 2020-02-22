//
//  ContentView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    TabView {
      ShoppingListScreen()
        .tabItem {
          Image(systemName: "cart")
          Text("Mercado")
      }
      FinancesScreen()
        .tabItem {
          Image(systemName: "dollarsign.circle")
          Text("Finanças")
      }
    }
    .font(.headline)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
