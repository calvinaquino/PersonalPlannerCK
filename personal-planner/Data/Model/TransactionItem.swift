//
//  TransactionItem.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI
import CloudKit
import Combine

class TransactionItem: Record {
  override class var recordType: String {
    "TransactionItem"
  }
  
  static func ==(lhs: TransactionItem, rhs: TransactionItem) -> Bool {(
    lhs.id == rhs.id &&
    lhs.name == rhs.name &&
    lhs.location == rhs.location &&
    lhs.value == rhs.value &&
    lhs.isInflow == rhs.isInflow &&
    lhs.day == rhs.day &&
    lhs.month == rhs.month &&
    lhs.year == rhs.year &&
    lhs.transactionCategory == rhs.transactionCategory
  )}
  
  var name: String {
    get { self.ckRecord["name"] ?? "" }
    set { self.ckRecord["name"] = newValue }
  }
  var location: String {
    get { self.ckRecord["location"] ?? "" }
    set { self.ckRecord["location"] = newValue }
  }
  var value: Double {
    get { self.ckRecord["value"] ?? 0.0 }
    set { self.ckRecord["value"] = newValue }
  }
  var isInflow: Bool {
    get { self.ckRecord["isInflow"] ?? false }
    set { self.ckRecord["isInflow"] = newValue}
  }
  var day: Int {
    get { self.ckRecord["day"] ?? 0 }
    set { self.ckRecord["day"] = newValue }
  }
  var month: Int {
    get { self.ckRecord["month"] ?? 0 }
    set { self.ckRecord["month"] = newValue }
  }
  var year: Int {
    get { self.ckRecord["year"] ?? 0 }
    set { self.ckRecord["year"] = newValue }
  }
  
  var valueSigned: Double {
    isInflow ? value : -value
  }
  
  var transactionCategory: TransactionCategory? {
    get {
      if let reference = self.ckRecord["transactionCategory"] as? CKRecord.Reference {
        let record = CKRecord(recordType: TransactionCategory.recordType, recordID: reference.recordID)
        let cached = Store.shared.transactionCategories.items.first { $0.id == record.id }
        return cached ?? TransactionCategory(with: record)
      }
      return nil
    }
    set {
      if let newShoppingCategory = newValue {
        let reference = CKRecord.Reference(recordID: newShoppingCategory.ckRecord!.recordID, action: .none)
        self.ckRecord["transactionCategory"] = reference
      } else {
        self.ckRecord["transactionCategory"] = nil
      }
    }
  }
  
  override func onSave() {
    Store.shared.transactionItems.save(self)
  }
  
  override func onDelete() {
    Store.shared.transactionItems.delete(self.id)
  }
  
  class func predicate(month: Int, year: Int) -> NSPredicate {
    let monthPredicate = NSPredicate(format: "month == %@", month.numberValue)
    let yearPredicate = NSPredicate(format: "year == %@", year.numberValue)
    return NSCompoundPredicate(andPredicateWithSubpredicates: [monthPredicate, yearPredicate])
  }
}

class TransactionItems: ObservableObject {
  static let shared = TransactionItems(date: Date())
  
  required init(date: Date) {
    self.date = date
    self.itemSubscriber = Store.shared.transactionItems.publisher
      .receive(on: RunLoop.main)
      .map({ $0.filter { $0.month == self.date.month && $0.year == self.date.year }.sorted{ $0.name < $1.name } })
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
  @Published private var _items: [TransactionItem] = []
  @Published private var _filteredItems: [TransactionItem] = []
  var query: String = "" {
    didSet { self._filteredItems = _items.filter{ self.filterPredicate().evaluate(with: $0.name) } }
  }
  
  func filterPredicate() -> NSPredicate {
    NSPredicate(format: "SELF CONTAINS[c] %@", self.query)
  }
  
  var date: Date! {
    didSet {
      if oldValue != self.date {
        self.fetch()
      }
    }
  }
  
  func fetch() {
    Cloud.fetchTransactionItems(for: self.date.month, year: self.date.year) { }
  }
  
  var items: [TransactionItem] {
    return self.query.isEmpty ? _items : _filteredItems
  }
}

