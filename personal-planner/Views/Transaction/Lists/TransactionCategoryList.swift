//
//  TransactionCategoryList.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-24.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct TransactionCategoryList: View {
  @State private var transactionCategories = TransactionCategories.shared

  var query: String
  @Binding private var showingFormScreen: Bool
  @Binding private var editingItem: TransactionCategory?
  
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
    }
    .onChange(of: query) { _, newValue in
      transactionCategories.query = newValue
    }
    .onAppear {
      transactionCategories.query = query
    }
  }
  
  func delete(at offsets: IndexSet) {
    for offset in offsets {
      let item = self.transactionCategories.items[offset]
      item.delete()
    }
  }
}

struct TransactionCategoryList_Previews: PreviewProvider {
  static var previews: some View {
    return TransactionCategoryList(query: "", editingItem: .constant(nil), showingFormScreen: .constant(false))
  }
}
