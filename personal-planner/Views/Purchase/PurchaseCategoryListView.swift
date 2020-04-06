//
//  PurchaseCategoryListView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-04-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct PurchaseCategoryListView: View {
  @State private var showingFormScreen = false
  @State private var searchText: String = ""
  @State private var editingItem: PurchaseCategory?
  
  var body: some View {
    VStack {
      HStack {
        SearchBar(searchText: self.$searchText)
        if searchText.isEmpty {
          RefreshButton(action: {
            Cloud.fetchPurchaseCategories { }
          })
        }
      }
      PurchaseCategoryList(
        query: self.searchText,
        editingItem: self.$editingItem,
        showingFormScreen: self.$showingFormScreen
      )
    }
    .sheet(isPresented: $showingFormScreen) {
        PurchaseCategoryFormView(with: nil)
    }
    .navigationBarTitle("Categories", displayMode: .inline)
    .navigationBarItems(trailing: Button(action: { self.showingFormScreen.toggle() }) {
//      Image(systemName: "plus")
      Text("Novo")
    })
  }
}

struct PurchaseCategoryListView_Previews: PreviewProvider {
  static var previews: some View {
    PurchaseCategoryListView()
  }
}
