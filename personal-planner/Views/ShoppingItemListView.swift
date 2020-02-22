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
  
  @FetchRequest(fetchRequest: ShoppingItem.allFetchRequest()) var shoppingItems: FetchedResults<ShoppingItem>
  @State private var showingFormScreen = false
  @State private var editingItem: ShoppingItem?
  
  var body: some View {
    NavigationView {
      VStack {
        SearchBar()
        List {
          ForEach(self.shoppingItems) { item in
            Text(item.name)
              .onTapGesture {
                self.editingItem = item
                self.showingFormScreen.toggle()
              }
          }
          .onDelete(perform: self.delete)
        }
      }
      .navigationBarTitle("Mercado", displayMode: .inline)
      .navigationBarItems(trailing: Button(action: {
        self.showingFormScreen.toggle()
      }) {
        Image(systemName: "plus")
      })
        .sheet(isPresented: $showingFormScreen, onDismiss: {
          self.editingItem = nil
        }) {
          ShoppingItemFormView(with: self.editingItem).environment(\.managedObjectContext, Store.context)
      }
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

struct ShoppingItemListView_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingItemListView()
  }
}
