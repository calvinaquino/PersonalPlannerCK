//
//  TransactionItemList.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-23.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Combine
import SwiftUI

// This solves havign a dynamic FetchRequest, based on:
// https://www.hackingwithswift.com/books/ios-swiftui/dynamically-filtering-fetchrequest-with-swiftui

struct TransactionItemList: View {
  
  var fetchRequest: FetchRequest<TransactionItem>
  @State private var showingFormScreen = false
  @State private var editingItem: TransactionItem?
  private var totalTransaction: Binding<Double>
  
  init(month: Int16, year: Int16, total: Binding<Double>, query: String) {
    var predicate: NSPredicate? = nil
    if !query.isEmpty {
      predicate = NSPredicate(format: "month == %@ AND year == %@ AND name CONTAINS[c] %@ ", month.numberValue, year.numberValue, query)
    } else {
      predicate = NSPredicate(format: "month == %@ AND year == %@", month.numberValue, year.numberValue)
    }
    fetchRequest = FetchRequest<TransactionItem>(entity: TransactionItem.entity(), sortDescriptors: [], predicate: predicate)
    totalTransaction = total
  }
  
  var body: some View {
    List {
      ForEach(fetchRequest.wrappedValue, id: \.self) { item in
        HStack {
          Text(item.name)
          Spacer()
          Text(String(item.value))
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
          TransactionItemFormView(with: self.editingItem).environment(\.managedObjectContext, Store.context)
      }
      .onAppear {
        self.updateTotals()
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
  
  func updateTotals() {
    self.totalTransaction.wrappedValue = self.fetchRequest.wrappedValue.reduce(0) { $1.value + $0 }
  }
}

struct TransactionItemList_Previews: PreviewProvider {
  static var previews: some View {
    TransactionItemList(month: 2, year: 2020, total: .constant(200.0), query: "")
  }
}
