//
//  TransactionCategory.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI
import CloudKit
import Combine

class TransactionCategory: Record {
  override class var recordType: String {
    "TransactionCategory"
  }
  
  static func ==(lhs: TransactionCategory, rhs: TransactionCategory) -> Bool {(
    lhs.id == rhs.id &&
    lhs.name == rhs.name &&
    lhs.budget == rhs.budget
  )}
  
  var name: String {
    get { self.ckRecord["name"] ?? "" }
    set { self.ckRecord["name"] = newValue }
  }
  var budget: Double {
    get { self.ckRecord["budget"] ?? 0.0 }
    set { self.ckRecord["budget"] = newValue }
  }
  
  override func onSave() {
    Store.shared.transactionCategories.save(self)
  }
  
  override func onDelete() {
    Store.shared.transactionCategories.delete(self.id)
  }
}

class TransactionCategories: ObservableObject {
  static let shared = TransactionCategories()
  
  required init() {
    self.itemSubscriber = Store.shared.transactionCategories.publisher
      .receive(on: RunLoop.main)
      .map({ $0.sorted{ $0.name < $1.name } })
      .sink(receiveValue: { items in
        if self.query.isEmpty {
            self._items = items
        } else {
            self._filteredItems = items.filter{ self.filterPredicate().evaluate(with: $0.name) }
        }
      })
  }
  
  deinit {
    self.itemSubscriber.cancel()
  }
  
  var itemSubscriber: AnyCancellable!
  @Published private var _items: [TransactionCategory] = []
  @Published private var _filteredItems: [TransactionCategory] = []
  var query: String = "" {
    didSet { self._filteredItems = _items.filter{ self.filterPredicate().evaluate(with: $0.name) } }
  }
  
  func filterPredicate() -> NSPredicate {
    NSPredicate(format: "SELF CONTAINS[c] %@", self.query)
  }
  
  func fetch() {
    Cloud.fetchTransactionCategories { }
  }
  
  var items: [TransactionCategory] {
    return self.query.isEmpty ? _items : _filteredItems
  }
}
