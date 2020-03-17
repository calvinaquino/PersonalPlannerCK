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
  
  @Binding private var showingFormScreen: Bool
  @Binding private var editingItem: ShoppingCategory?
  
  init(query: String, editingItem: Binding<ShoppingCategory?>, showingFormScreen: Binding<Bool>) {
    self._editingItem = editingItem
    self._showingFormScreen = showingFormScreen
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
    }
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
    ShoppingCategoryList(query: "", editingItem: .constant(nil), showingFormScreen: .constant(false))
  }
}
