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
  @State private var searchText: String = ""
  
  var body: some View {
    NavigationView {
      VStack {
        SearchBar(searchText: self.$searchText)
        ShoppingItemList(query: searchText)
        .sheet(isPresented: $showingFormScreen) {
            ShoppingItemFormView(with: nil).environment(\.managedObjectContext, Store.context)
        }
      }
      .navigationBarTitle("Mercado", displayMode: .inline)
      .navigationBarItems(leading: NavigationLink(destination: ShoppingCategoryListView()) {
        Image(systemName: "folder")
        }, trailing: Button(action: { self.showingFormScreen.toggle()}) {
        Image(systemName: "plus")
      })
    }
  }
}

struct ShoppingItemListView_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingItemListView()
  }
}
