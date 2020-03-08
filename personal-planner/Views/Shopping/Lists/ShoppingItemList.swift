//
//  ShoppingItemList.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-23.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct ShoppingItemList: View {
  
  @ObservedObject private var shoppingItems = ShoppingItems.shared
  @ObservedObject private var shoppingCategories = ShoppingCategories.shared
  
  @Binding var isFiltering: Bool
  
  @State private var showingFormScreen = false
  @State private var editingItem: ShoppingItem?
  @State private var rotation: Double = 0.0;
  
  init(query: String, isFiltering: Binding<Bool>) {
    self._isFiltering = isFiltering
    self.shoppingItems.query = query
  }
  
  var sections: [ShoppingSection] {
    ShoppingSection.sections(items: shoppingItems.items, categories: shoppingCategories.items, filter: self.isFiltering)
  }
  
  var body: some View {
    List {
      ForEach(sections, id: \.id) { section in
        Section(header: HStack {
          Text(section.categoryName)
          Spacer()
          Text(self.isFiltering ? section.items.count.stringValue : section.countVersusTotal)
        }) {
          ForEach(section.items, id: \.id) { item in
            ShoppingItemRow(item: item) {
              self.editingItem = $0
              self.showingFormScreen = true
            }
          }
          .onDelete(perform: { offsets in
            self.delete(at: offsets, in: section)
          })
        }
      }
      .sheet(isPresented: self.$showingFormScreen, onDismiss: {
        self.editingItem = nil
      }) {
        ShoppingItemFormView(with: self.editingItem)
      }
    }
  }
  
  func delete(at offsets: IndexSet, in section: ShoppingSection) {
    for offset in offsets {
      let item = section.items[offset]
      item.delete()
    }
  }
}

struct ShoppingItemList_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingItemList(query: "", isFiltering: .constant(false))
  }
}
