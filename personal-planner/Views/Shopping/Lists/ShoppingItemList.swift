//
//  ShoppingItemList.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-23.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct ShoppingItemList: View {
  
  var fetchRequest: FetchRequest<ShoppingItem>
  
  @State private var showingFormScreen = false
  @State private var editingItem: ShoppingItem?
  
  init(query: String) {
    var predicate: NSPredicate? = nil
    if !query.isEmpty {
      predicate = NSPredicate(format: "name CONTAINS[c] %@", query)
    }
    fetchRequest = FetchRequest<ShoppingItem>(entity: ShoppingItem.entity(), sortDescriptors: [], predicate: predicate)
  }
  
  var body: some View {
    List {
      ForEach(fetchRequest.wrappedValue, id: \.self) { item in
        HStack {
          Text(item.name)
          Spacer()
          Image(systemName: item.isNeeded ? "cube.box" : "cube.box.fill")
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
      .onDelete(perform: self.delete)
      .sheet(isPresented: self.$showingFormScreen, onDismiss: {
          self.editingItem = nil
        }) {
          ShoppingItemFormView(with: self.editingItem).environment(\.managedObjectContext, Store.context)
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

struct ShoppingItemList_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingItemList(query: "")
  }
}
