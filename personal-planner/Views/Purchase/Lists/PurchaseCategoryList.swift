//
//  PurchaseCategoryList.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-04-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct PurchaseCategoryList: View {
  
  @ObservedObject private var purchaseCategories = PurchaseCategories.shared
  
  @Binding private var showingFormScreen: Bool
  @Binding private var editingItem: PurchaseCategory?
  
  init(query: String, editingItem: Binding<PurchaseCategory?>, showingFormScreen: Binding<Bool>) {
    self._editingItem = editingItem
    self._showingFormScreen = showingFormScreen
    self.purchaseCategories.query = query
  }
  
  var body: some View {
    List {
      ForEach(purchaseCategories.items, id: \.id) { item in
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
      let item = self.purchaseCategories.items[offset]
      item.delete()
    }
  }
}

struct PurchaseCategoryList_Previews: PreviewProvider {
  static var previews: some View {
    PurchaseCategoryList(query: "", editingItem: .constant(nil), showingFormScreen: .constant(false))
  }
}
