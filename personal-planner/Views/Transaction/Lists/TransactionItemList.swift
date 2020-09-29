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
  
  @Binding private var showingFormScreen: Bool
  @Binding private var editingItem: TransactionItem?
  private var totalTransaction: Binding<Double>
  
  init(date: Date, total: Binding<Double>, query: String, editingItem: Binding<TransactionItem?>, showingFormScreen: Binding<Bool>) {
    _transactionItems.wrappedValue.query = query
    _transactionItems.wrappedValue.date = date
    totalTransaction = total
    _editingItem = editingItem
    _showingFormScreen = showingFormScreen
  }
  
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
  }
}

struct TransactionItemList_Previews: PreviewProvider {
  static var previews: some View {
    Mock.mockTransactions()
    return Group {
      TransactionItemList(date: Date(), total: .constant(200.0), query: "", editingItem: .constant(nil), showingFormScreen: .constant(false))
        .previewLayout(.sizeThatFits)
        .frame(width: 350, height: 250, alignment: .top)
      TransactionItemList(date: Date(), total: .constant(200.0), query: "", editingItem: .constant(nil), showingFormScreen: .constant(false))
        .colorScheme(.dark)
        .previewLayout(.sizeThatFits)
        .frame(width: 350, height: 250, alignment: .top)
    }
  }
}
