//
//  ShoppingItemList.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-23.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct ShoppingItemList: View {
  
  var itemFetchRequest: FetchRequest<ShoppingItem>
  var categoryfetchRequest: FetchRequest<ShoppingCategory>
  
  @State private var showingFormScreen = false
  @State private var editingItem: ShoppingItem?
  
  init(query: String) {
    var predicate: NSPredicate? = nil
    if !query.isEmpty {
      predicate = NSPredicate(format: "name CONTAINS[c] %@", query)
    }
    itemFetchRequest = FetchRequest<ShoppingItem>(entity: ShoppingItem.entity(), sortDescriptors: [], predicate: predicate)
    categoryfetchRequest = FetchRequest<ShoppingCategory>(entity: ShoppingCategory.entity(), sortDescriptors: [])
  }
  
  var sections: [ShoppingSection] {
    ShoppingSection.sections(items: itemFetchRequest, categories: categoryfetchRequest)
  }
  
  var body: some View {
    List {
      ForEach(sections, id: \.categoryName) { section in
        Section(header: Text(section.categoryName)) {
          ForEach(section.items, id: \.id) { item in
            HStack {
              Text(item.name)
              Text(item.price.stringCurrencyValue)
              Spacer()
              Image(systemName: item.isNeeded ? "cube.box" : "cube.box.fill")
              .contentShape(Rectangle())
              .foregroundColor(Color(.systemBlue))
              .onTapGesture {
                item.isNeeded.toggle()
                Store.save()
              }
            }
            .contentShape(Rectangle())
            .onTapGesture {
              self.editingItem = item
              self.showingFormScreen.toggle()
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
          ShoppingItemFormView(with: self.editingItem).environment(\.managedObjectContext, Store.context)
      }
    }
  }
  
  func delete(at offsets: IndexSet, in section: ShoppingSection) {
    for offset in offsets {
      let item = section.items[offset]
      Store.context.delete(item)
    }
    Store.save()
  }
}

struct ShoppingItemList_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingItemList(query: "").environment(\.managedObjectContext, Store.context)
  }
}
