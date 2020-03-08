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
  
  var body: some View {
    VStack {
      HStack {
        SearchBar(searchText: self.$searchText)
        if searchText.isEmpty {
          RefreshButton(action: {
            Cloud.fetchShoppingCategories { }
          })
        }
      }
      ShoppingCategoryList(query: self.searchText)
        .sheet(isPresented: $showingFormScreen) {
          ShoppingCategoryFormView(with: nil)
      }
    }
    .navigationBarTitle("Categories", displayMode: .inline)
    .navigationBarItems(trailing: Button(action: { self.showingFormScreen.toggle() }) {
//      Image(systemName: "plus")
      Text("Novo")
    })
  }
}

struct ShoppingCategoryListView_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingCategoryListView()
  }
}
