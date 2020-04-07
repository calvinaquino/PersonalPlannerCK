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

final class TransactionCategory: NSObject, Record, Named {
  var ckRecord: CKRecord!
  var deleted: Bool
  
  required init(with record: CKRecord?) {
    self.deleted = false
    self.ckRecord = record
  }
  
  static func makeRecord(with record: CKRecord) -> TransactionCategory {
    TransactionCategory(with: record)
  }
  
  static func store() -> Cache<TransactionCategory> {
    return Store.shared.transactionCategories
  }
  
  static var recordType: String {
    CKRecord.RecordType.TransactionCategory
  }
  
  var budget: Double {
    get { self.ckRecord["budget"] ?? 0.0 }
    set { self.ckRecord["budget"] = newValue }
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
