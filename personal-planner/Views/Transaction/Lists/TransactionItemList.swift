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
  
  @ObservedObject private var transactionItems = TransactionItems.shared
  @ObservedObject private var transactionCategories = TransactionCategories.shared
  
  @State private var showingFormScreen = false
  @State private var editingItem: TransactionItem?
  private var totalTransaction: Binding<Double>
  
  init(date: Date, total: Binding<Double>, query: String) {
    _transactionItems.wrappedValue.query = query
    _transactionItems.wrappedValue.date = date
    totalTransaction = total
  }
  
  var sections: [TransactionSection] {
    TransactionSection.sections(items: transactionItems.items, categories: transactionCategories.items)
  }
  
  var body: some View {
    List {
      ForEach(sections, id: \.id) { section in
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
        TransactionItemFormView(with: self.editingItem, date: nil)
          .onDisappear {
            self.updateTotals()
        }
      }
    }
    .overlay(
      RefreshButton(action: {
        self.transactionCategories.fetch()
        self.transactionItems.fetch()
      })
    , alignment: .bottomTrailing)
  }
  
  func delete(at offsets: IndexSet, in section: TransactionSection) {
    for offset in offsets {
      let item = section.transactions[offset]
      item.delete()
    }
  }
  
  func updateTotals() {
    self.totalTransaction.wrappedValue = self.transactionItems.items.reduce(0) { $1.valueSigned + $0 }
  }
}

struct TransactionItemList_Previews: PreviewProvider {
  static var previews: some View {
    return TransactionItemList(date: Date(), total: .constant(200.0), query: "")
  }
}
