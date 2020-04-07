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

final class TransactionItem: NSObject, Record, Named, Valued, Dated, Located {
  var ckRecord: CKRecord!
  var deleted: Bool
  
  required init(with record: CKRecord?) {
    self.deleted = false
    self.ckRecord = record
  }
  
  static func makeRecord(with record: CKRecord) -> TransactionItem {
    TransactionItem(with: record)
  }
  
  static func store() -> Cache<TransactionItem> {
    return Store.shared.transactionItems
  }
  
  static var recordType: String {
    CKRecord.RecordType.TransactionItem
  }
  
  static func predicate(month: Int, year: Int) -> NSPredicate {
    let monthPredicate = NSPredicate(format: "month == %@", month.numberValue)
    let yearPredicate = NSPredicate(format: "year == %@", year.numberValue)
    return NSCompoundPredicate(andPredicateWithSubpredicates: [monthPredicate, yearPredicate])
  }
}

extension TransactionItem: Categorized {
  typealias ParentCategory = TransactionCategory
  
  var categoryKey: String { "transactionCategory" }
  
  func makeCategory(with record: CKRecord) -> TransactionCategory {
    TransactionCategory(with: record)
  }
}

class TransactionItems: ObservableObject {
  static let shared = TransactionItems(date: Date())
  
  required init(date: Date) {
    self.date = date
    self.itemSubscriber = Store.shared.transactionItems.publisher
      .receive(on: RunLoop.main)
      .map({ $0.filter { $0.date.month == self.date.month && $0.date.year == self.date.year }.sorted{ $0.name < $1.name } })
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
    Cloud.fetchTransactionItems(for: self.date) { }
  }
  
  var items: [TransactionItem] {
    return self.query.isEmpty ? _items : _filteredItems
  }
}

