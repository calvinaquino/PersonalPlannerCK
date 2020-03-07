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
            ShoppingItemFormView(with: nil)
        }
      }
      .navigationBarTitle("Mercado", displayMode: .inline)
      .navigationBarItems(leading: NavigationLink(destination: ShoppingCategoryListView()) {
//        Image(systemName: "folder")
        Text("Categorias")
        }, trailing: Button(action: { self.showingFormScreen.toggle()}) {
//        Image(systemName: "plus")
          Text("Novo")
      })
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

struct ShoppingItemListView_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingItemListView()
  }
}
