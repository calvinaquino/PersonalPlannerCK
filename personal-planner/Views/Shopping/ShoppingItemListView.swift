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
  
  var body: some View {
    NavigationView {
      VStack {
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
        ShoppingItemList(
          query: searchText,
          editingItem: self.$editingItem,
          isFiltering: self.$isActive,
          showingFormScreen: self.$showingFormScreen
        )
      }
      .navigationBarTitle("Mercado", displayMode: .inline)
      .navigationBarItems(leading: NavigationLink(destination: ShoppingCategoryListView()) {
//        Image(systemName: "folder")
        Text("Categorias")
        }, trailing: Button(action: {
          self.editingItem = nil
          self.showingFormScreen.toggle()
        }) {
//        Image(systemName: "plus")
          Text("Novo")
      })
    }
    .sheet(isPresented: $showingFormScreen) {
      ShoppingItemFormView(with: self.$editingItem.wrappedValue)
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

struct ShoppingItemListView_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingItemListView()
  }
}
