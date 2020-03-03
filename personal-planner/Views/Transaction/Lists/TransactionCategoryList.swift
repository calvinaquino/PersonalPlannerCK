//
//  TransactionCategoryList.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-24.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct TransactionCategoryList: View {
  @ObservedObject private var transactionCategories = TransactionCategories()
  
  @State private var showingFormScreen = false
  @State private var editingItem: TransactionCategory?
  
  init(query: String) {
    self.transactionCategories.query = query
  }
  
  var body: some View {
    List {
      ForEach(transactionCategories.items, id: \.id) { item in
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
        TransactionCategoryFormView(with: self.editingItem)
      }
    }
    .onAppear{
      self.transactionCategories.fetch()
    }
  }
  
  func delete(at offsets: IndexSet) {
    for offset in offsets {
      let item = self.transactionCategories.items[offset]
      item.save()
    }
  }
}

//struct TransactionCategoryList_Previews: PreviewProvider {
//  static var previews: some View {
//    
//    let item1 = TransactionCategory()
//    item1.name = "Mercado"
//    item1.budget = 500.0
//    
//    return TransactionCategoryList(query: "").environment(\.managedObjectContext, Store.context)
//  }
//}
