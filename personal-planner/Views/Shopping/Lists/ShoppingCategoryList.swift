//
//  ShoppingCategoryList.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-24.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct ShoppingCategoryList: View {
  
  @ObservedObject private var shoppingCategories = ShoppingCategories.shared
  
  @State private var showingFormScreen = false
  @State private var editingItem: ShoppingCategory?
  
  init(query: String) {
    self.shoppingCategories.query = query
  }
  
  var body: some View {
    List {
      ForEach(shoppingCategories.items, id: \.id) { item in
        HStack {
          Text(item.name)
          Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
          self.editingItem = item
          self.showingFormScreen.toggle()
        }
      }
      .onDelete(perform: self.delete)
      .sheet(isPresented: self.$showingFormScreen, onDismiss: {
        self.editingItem = nil
      }) {
        ShoppingCategoryFormView(with: self.editingItem)
      }
      Rectangle().foregroundColor(.clear)
    }
    .overlay(
      RefreshButton(action: {
        self.shoppingCategories.fetch()
      })
      , alignment: .bottomTrailing)
  }
  
  func delete(at offsets: IndexSet) {
    for offset in offsets {
      let item = self.shoppingCategories.items[offset]
      item.delete()
    }
  }
}

struct ShoppingCategoryList_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingCategoryList(query: "")
  }
}
