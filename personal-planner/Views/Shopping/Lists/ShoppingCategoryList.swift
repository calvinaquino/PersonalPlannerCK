//
//  ShoppingCategoryList.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-24.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct ShoppingCategoryList: View {
  
  var fetchRequest: FetchRequest<ShoppingCategory>
  
  @State private var showingFormScreen = false
  @State private var editingItem: ShoppingCategory?
  
  init(query: String) {
    var predicate: NSPredicate? = nil
    if !query.isEmpty {
      predicate = NSPredicate(format: "name CONTAINS[c] %@", query)
    }
    fetchRequest = FetchRequest<ShoppingCategory>(entity: ShoppingCategory.entity(), sortDescriptors: [], predicate: predicate)
  }
  
  var body: some View {
    List {
      ForEach(fetchRequest.wrappedValue, id: \.self) { item in
        HStack {
          Text(item.name)
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
          ShoppingCategoryFormView(with: self.editingItem).environment(\.managedObjectContext, Store.context)
      }
    }
  }
  
  func delete(at offsets: IndexSet) {
    for offset in offsets {
      let item = self.fetchRequest.wrappedValue[offset]
      Store.context.delete(item)
    }
    Store.save()
  }
}

struct ShoppingCategoryList_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingCategoryList(query: "")
    }
}
