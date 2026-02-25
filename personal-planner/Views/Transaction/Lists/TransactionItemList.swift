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
  
  @State private var transactionItems = TransactionItems.shared
  @State private var transactionCategories = TransactionCategories.shared

  var date: Date
  var totalTransaction: Binding<Double>
  var query: String
  @Binding private var showingFormScreen: Bool
  @Binding private var editingItem: TransactionItem?
  
  var sections: [TransactionSection] {
    TransactionSection.sections(items: transactionItems.items, categories: transactionCategories.items)
  }
  
  func delete(at offsets: IndexSet, in section: TransactionSection) {
    for offset in offsets {
      let item = section.transactions[offset]
      item.delete()
    }
  }
  
  func updateTotals() {
    self.totalTransaction.wrappedValue = self.sections.reduce(0) { $1.total + $0 }
  }
  
  func openFormScreen(for item: TransactionItem) {
    self.editingItem = item
    self.showingFormScreen.toggle()
  }
  
  var body: some View {
    List {
      ForEach(sections, id: \.id) { section in
        Section(header: SectionView(title: section.categoryName, rightText: section.currentVersusTotal)
        ) {
          ForEach(section.transactions, id: \.id) { item in
            TransactionItemRow(item: item) {
              self.openFormScreen(for: $0)
            }
            .contextMenu {
              Button("Remover", action: { item.delete() })
              Button("Efetuar", action: {
                item.isComplete.toggle()
                item.save()
                self.updateTotals()
              })
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
    }
    .onChange(of: query) { _, newValue in
      transactionItems.query = newValue
    }
    .onChange(of: date) { _, newValue in
      transactionItems.date = newValue
    }
    .onAppear {
      transactionItems.query = query
      transactionItems.date = date
    }
  }
}

struct TransactionItemList_Previews: PreviewProvider {
  static var previews: some View {
    Mock.mockTransactions()
    return Group {
      TransactionItemList(date: Date(), totalTransaction: .constant(200.0), query: "", editingItem: .constant(nil), showingFormScreen: .constant(false))
        .previewLayout(.sizeThatFits)
        .frame(width: 350, height: 250, alignment: .top)
      TransactionItemList(date: Date(), totalTransaction: .constant(200.0), query: "", editingItem: .constant(nil), showingFormScreen: .constant(false))
        .colorScheme(.dark)
        .previewLayout(.sizeThatFits)
        .frame(width: 350, height: 250, alignment: .top)
    }
  }
}
