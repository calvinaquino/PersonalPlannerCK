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
  @Binding private var showingFormScreen: Bool
  @Binding private var editingItem: ShoppingItem?
  @State private var rotation: Double = 0.0;
  
  init(query: String, editingItem: Binding<ShoppingItem?>, isFiltering: Binding<Bool>, showingFormScreen: Binding<Bool>) {
    self._isFiltering = isFiltering
    self._editingItem = editingItem
    self._showingFormScreen = showingFormScreen
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
            .contextMenu {
              Button("Remover", action: { item.delete() })
              Button(item.isNeeded ? "Adquirido" : "Faltando", action: {
                item.isNeeded.toggle()
                item.save()
              })
            }
          }
          .onDelete(perform: { offsets in
            self.delete(at: offsets, in: section)
          })
        }
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
    ShoppingItemList(query: "", editingItem: .constant(nil), isFiltering: .constant(false), showingFormScreen: .constant(false))
  }
}
