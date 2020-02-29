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
      SearchBar(searchText: self.$searchText)
      ShoppingCategoryList(query: self.searchText)
        .sheet(isPresented: $showingFormScreen) {
          ShoppingCategoryFormView(with: nil).environment(\.managedObjectContext, Store.context)
      }
    }
    .navigationBarTitle("Categories", displayMode: .inline)
    .navigationBarItems(trailing: Button(action: { self.showingFormScreen.toggle() }) {
      Image(systemName: "plus")
    })
  }
}

struct ShoppingCategoryListView_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingCategoryListView().environment(\.managedObjectContext, Store.context)
  }
}
