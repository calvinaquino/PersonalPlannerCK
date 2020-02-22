//
//  ShoppingListScreen.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Combine
import SwiftUI

struct ShoppingListScreen: View {
  
  @FetchRequest(fetchRequest: ShoppingItem.allFetchRequest()) var shoppingItems: FetchedResults<ShoppingItem>
  
  var body: some View {
    NavigationView {
      VStack {
        SearchBar()
        List {
          ForEach(self.shoppingItems) { item in
            Text(item.name)
          }
          .onDelete(perform: self.delete)
        }
      }
      .navigationBarTitle("Mercado", displayMode: .inline)
      .navigationBarItems(trailing: Button(action: {
        let newItem = ShoppingItem()
        newItem.name = "What"
        Store.save()
      }) {
        Image(systemName: "plus")
      })
    }
  }
  
  func delete(at offsets: IndexSet) {
    for offset in offsets {
      let item = self.shoppingItems[offset]
      Store.context.delete(item)
    }
    Store.save()
  }
}

struct ShoppingListScreen_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingListScreen()
  }
}
