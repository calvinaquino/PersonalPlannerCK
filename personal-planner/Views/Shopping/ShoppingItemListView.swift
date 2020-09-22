//
//  ShoppingItemListView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Combine
import SwiftUI

struct ShoppingItemListView: View {
  
  @State private var showingFormScreen = false
  @State private var editingItem: ShoppingItem? = nil
  @State private var searchText: String = ""
  @State private var isActive = false
  
  func showFormScreen() {
    self.editingItem = nil
    self.showingFormScreen.toggle()
  }
  
  var body: some View {
    StackNavigationView {
      VStack {
        Header(searchText: $searchText, isActive: $isActive)
        ShoppingItemList(
          query: searchText,
          editingItem: self.$editingItem,
          isFiltering: self.$isActive,
          showingFormScreen: self.$showingFormScreen
        )
      }
      .navigationBarTitle("Mercado", displayMode: .inline)
      .navigationBarItems(leading: NavigationLink(destination: ShoppingCategoryListView()) {
        IconButton(systemIcon: "folder")
      }, trailing: Button(action: self.showFormScreen) {
        IconButton(systemIcon: "plus")
      })
    }
    .sheet(isPresented: $showingFormScreen) {
      ShoppingItemFormView(with: self.$editingItem.wrappedValue)
    }
  }
  
  struct Header: View {
    @Binding var searchText: String
    @Binding var isActive: Bool
    var body: some View {
      HStack {
        SearchBar(searchText: self.$searchText)
        if searchText.isEmpty {
          FilterButton(isActive: self.$isActive) {
            self.isActive.toggle()
          }
          RefreshButton(action: {
            Cloud.fetchShoppingCategories { }
            Cloud.fetchShoppingItems { }
          })
        }
      }
    }
  }
}

struct ShoppingItemListView_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingItemListView()
  }
}
