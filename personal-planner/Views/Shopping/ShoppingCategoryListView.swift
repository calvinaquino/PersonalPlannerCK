//
//  ShoppingCategoryListView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-23.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct ShoppingCategoryListView: View {
  @State private var showingFormScreen = false
  @State private var searchText: String = ""
  @State private var editingItem: ShoppingCategory?
  
  var body: some View {
    VStack {
      ShoppingCategoryList(
        query: self.searchText,
        editingItem: self.$editingItem,
        showingFormScreen: self.$showingFormScreen
      )
      .searchable(text: $searchText)
    }
    .sheet(isPresented: $showingFormScreen) {
        ShoppingCategoryFormView(with: nil)
    }
    .navigationBarTitle("Categories", displayMode: .inline)
    .toolbar {
      ToolbarItemGroup(placement: .topBarTrailing) {
        RefreshButton(action: {
          Cloud.fetchShoppingCategories { }
        })
        Button(action: { self.showingFormScreen.toggle() }) {
            Text("Novo")
        }
      }
    }
  }
}

struct ShoppingCategoryListView_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingCategoryListView()
  }
}
