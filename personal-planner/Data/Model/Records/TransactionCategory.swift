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

class TransactionCategory: Record, Named, ObservableObject {
  override class var recordType: String {
    CKRecord.RecordType.TransactionCategory
  }
  
  static func ==(lhs: TransactionCategory, rhs: TransactionCategory) -> Bool {(
    lhs.id == rhs.id &&
    lhs.name == rhs.name &&
    lhs.budget == rhs.budget
  )}
  
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

class TransactionCategories: ObservableObject, Equatable, Identifiable {
  static let shared = TransactionCategories()
  
  let id: String = UUID().uuidString
  
  static func ==(lhs: TransactionCategories, rhs: TransactionCategories) -> Bool {(
    lhs.id == rhs.id &&
    lhs._items.count == rhs._items.count &&
    lhs._filteredItems.count == rhs._filteredItems.count &&
    lhs.query == rhs.query
  )}
  
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
