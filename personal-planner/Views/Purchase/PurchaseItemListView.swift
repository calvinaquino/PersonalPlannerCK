//
//  PurchaseItemListView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-04-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Combine
import SwiftUI

struct PurchaseItemListView: View {
  
  @State private var showingFormScreen = false
  @State private var editingItem: PurchaseItem? = nil
  @State private var searchText: String = ""
  @State private var isActive = false
  
  func showFormScreen() {
    self.editingItem = nil
    self.showingFormScreen.toggle()
  }
  
  var body: some View {
    StackNavigationView {
      VStack {
        HStack {
          SearchBar(searchText: self.$searchText)
          if searchText.isEmpty {
            FilterButton(isActive: self.$isActive) {
              self.isActive.toggle()
            }
            RefreshButton(action: {
              Cloud.fetchPurchaseCategories { }
              Cloud.fetchPurchaseItems { }
            })
          }
        }
        PurchaseItemList(
          query: searchText,
          editingItem: self.$editingItem,
          isFiltering: self.$isActive,
          showingFormScreen: self.$showingFormScreen
        )
      }
      .navigationBarTitle("Metas", displayMode: .inline)
      .navigationBarItems(leading: NavigationLink(destination: PurchaseCategoryListView()) {
        IconButton(systemIcon: "folder")
      }, trailing: Button(action: self.showFormScreen) {
        IconButton(systemIcon: "plus")
      })
    }
    .sheet(isPresented: $showingFormScreen) {
      PurchaseItemFormView(with: self.$editingItem.wrappedValue)
    }
  }
}

struct PurchaseItemListView_Previews: PreviewProvider {
  static var previews: some View {
    PurchaseItemListView()
  }
}
