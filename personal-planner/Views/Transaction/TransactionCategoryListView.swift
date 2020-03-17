//
//  TransactionCategoryListView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-23.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct TransactionCategoryListView: View {
  @State private var showingFormScreen = false
  @State private var searchText: String = ""
  @State private var editingItem: TransactionCategory?
  
  var body: some View {
    VStack {
      HStack {
        SearchBar(searchText: self.$searchText)
        if searchText.isEmpty {
          RefreshButton(action: {
            Cloud.fetchTransactionCategories { }
          })
        }
      }
      TransactionCategoryList(
        query: self.searchText,
        editingItem: self.$editingItem,
        showingFormScreen: self.$showingFormScreen
      )
    }
    .sheet(isPresented: $showingFormScreen) {
      TransactionCategoryFormView(with: self.$editingItem.wrappedValue)
    }
    .navigationBarTitle("Categorias", displayMode: .inline)
    .navigationBarItems(trailing: Button(action: {
      self.showingFormScreen.toggle()
    }) {
//      Image(systemName: "plus")
      Text("Novo")
    })
  }
}

struct TransactionCategoryListView_Previews: PreviewProvider {
  static var previews: some View {
    TransactionCategoryListView()
  }
}
