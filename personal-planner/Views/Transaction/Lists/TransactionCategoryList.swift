//
//  TransactionCategoryList.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-24.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct TransactionCategoryList: View {
  var fetchRequest: FetchRequest<TransactionCategory>
  
  @State private var showingFormScreen = false
  @State private var editingItem: TransactionCategory?
  
  init(query: String) {
    var predicate: NSPredicate? = nil
    if !query.isEmpty {
      predicate = NSPredicate(format: "name CONTAINS[c] %@", query)
    }
    fetchRequest = FetchRequest<TransactionCategory>(entity: TransactionCategory.entity(), sortDescriptors: [], predicate: predicate)
  }
  
  var body: some View {
    List {
      ForEach(fetchRequest.wrappedValue, id: \.self) { item in
        HStack {
          Text(item.name)
          Spacer()
          Text(item.budget.stringCurrencyValue)
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
        TransactionCategoryFormView(with: self.editingItem).environment(\.managedObjectContext, Store.context)
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

struct TransactionCategoryList_Previews: PreviewProvider {
  static var previews: some View {
    
    let item1 = TransactionCategory()
    item1.name = "Mercado"
    item1.budget = 500.0
    
    return TransactionCategoryList(query: "").environment(\.managedObjectContext, Store.context)
  }
}
