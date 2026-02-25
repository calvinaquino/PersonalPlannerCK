//
//  ShoppingCategoryList.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-24.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct ShoppingCategoryList: View {
  
  @State private var shoppingCategories = ShoppingCategories.shared

  var query: String
  @Binding private var showingFormScreen: Bool
  @Binding private var editingItem: ShoppingCategory?

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
    .onChange(of: query) { _, newValue in
      shoppingCategories.query = newValue
    }
    .onAppear {
      shoppingCategories.query = query
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
