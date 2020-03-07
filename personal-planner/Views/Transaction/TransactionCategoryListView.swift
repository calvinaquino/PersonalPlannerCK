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
  
  var body: some View {
    VStack {
      SearchBar(searchText: self.$searchText)
      TransactionCategoryList(query: self.searchText)
      .sheet(isPresented: $showingFormScreen) {
          TransactionCategoryFormView(with: nil)
      }
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
