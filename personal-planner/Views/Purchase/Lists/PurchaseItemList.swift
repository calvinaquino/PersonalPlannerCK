//
//  PurchaseItemList.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-04-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct PurchaseItemList: View {
  
  @ObservedObject private var purchaseItems = PurchaseItems.shared
  @ObservedObject private var purchaseCategories = PurchaseCategories.shared
  
  @Binding var isFiltering: Bool
  @Binding private var showingFormScreen: Bool
  @Binding private var editingItem: PurchaseItem?
  @State private var rotation: Double = 0.0;
  
  init(query: String, editingItem: Binding<PurchaseItem?>, isFiltering: Binding<Bool>, showingFormScreen: Binding<Bool>) {
    self._isFiltering = isFiltering
    self._editingItem = editingItem
    self._showingFormScreen = showingFormScreen
    self.purchaseItems.query = query
  }
  
  var sections: [PurchaseSection] {
    PurchaseSection.sections(items: purchaseItems.items, categories: purchaseCategories.items, filter: self.isFiltering)
  }
  
  var body: some View {
    List {
      ForEach(sections, id: \.id) { section in
        Section(header: HStack {
          Text(section.categoryName)
          Spacer()
        }) {
          ForEach(section.items, id: \.id) { item in
            PurchaseItemRow(item: item) {
              self.editingItem = $0
              self.showingFormScreen = true
            }
          }
          .onDelete(perform: { offsets in
            self.delete(at: offsets, in: section)
          })
        }
      }
    }
  }
  
  func delete(at offsets: IndexSet, in section: PurchaseSection) {
    for offset in offsets {
      let item = section.items[offset]
      item.delete()
    }
  }
}

struct PurchaseItemList_Previews: PreviewProvider {
  static var previews: some View {
    PurchaseItemList(query: "", editingItem: .constant(nil), isFiltering: .constant(false), showingFormScreen: .constant(false))
  }
}
