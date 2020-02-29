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
  
  var itemFetchRequest: FetchRequest<TransactionItem>
  var categoryfetchRequest: FetchRequest<TransactionCategory>

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
    itemFetchRequest = FetchRequest<TransactionItem>(entity: TransactionItem.entity(), sortDescriptors: [], predicate: predicate)
    totalTransaction = total
    categoryfetchRequest = FetchRequest<TransactionCategory>(entity: TransactionCategory.entity(), sortDescriptors: [])
  }
  
  var sections: [TransactionSection] {
    TransactionSection.sections(items: itemFetchRequest, categories: categoryfetchRequest)
  }
  
  var body: some View {
    List {
      ForEach(sections, id: \.categoryName) { section in
        Section(header: HStack{
          Text(section.categoryName)
          Spacer()
          Text(section.total.stringCurrencyValue)
        }) {
          ForEach(section.transactions, id: \.id) { item in
            HStack {
              Text(item.name)
              Spacer()
              Text(item.valueSigned.stringCurrencyValue)
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
          .onAppear {
            self.updateTotals()
          }
          .onDisappear {
            self.updateTotals()
          }
        }
      }
      .sheet(isPresented: self.$showingFormScreen, onDismiss: {
          self.editingItem = nil
        }) {
          TransactionItemFormView(with: self.editingItem)
            .environment(\.managedObjectContext, Store.context)
            .onDisappear {
              self.updateTotals()
            }
      }
    }
  }
  
  func delete(at offsets: IndexSet, in section: TransactionSection) {
    for offset in offsets {
      let item = section.transactions[offset]
      Store.context.delete(item)
    }
    Store.save()
  }
  
  func updateTotals() {
    self.totalTransaction.wrappedValue = self.itemFetchRequest.wrappedValue.reduce(0) { $1.valueSigned + $0 }
  }
}

struct TransactionItemList_Previews: PreviewProvider {
  static let month: Int16 = 2
  static let year: Int16 = 2020
  
  static var previews: some View {
    
    let item1 = TransactionItem()
    item1.name = "Compras"
    item1.value = 230.0
    item1.month = month
    item1.year = year
    
    let item2 = TransactionItem()
    item2.name = "Salario"
    item2.value = 2000
    item1.isInflow = true
    item2.month = month
    item2.year = year
    
    return TransactionItemList(month: month, year: year, total: .constant(200.0), query: "").environment(\.managedObjectContext, Store.context)
  }
}
