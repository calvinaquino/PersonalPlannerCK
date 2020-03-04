//
//  TransactionItem.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI
import CloudKit

class TransactionItem: Record {
  override class var recordType: String {
    "TransactionItem"
  }
  
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
  required init(month: Int, year: Int) {
    self.month = month
    self.year = year
    self.fetch()
    NotificationCenter.default.addObserver(self, selector: #selector(update), name: .transactionItem, object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  @Published private var _items: [TransactionItem] = []
  @Published private var _filteredItems: [TransactionItem] = []
  var query: String = "" {
    didSet {
      self.updateFilter()
    }
  }
  
  func updateFilter() {
    if !self.query.isEmpty {
      let predicate = NSPredicate(format: "SELF CONTAINS[c] %@", self.query)
      self._filteredItems = self._items.filter {
        predicate.evaluate(with: $0.name)
      }
    }
  }
  
  var month: Int! {
    didSet { self.update() }
  }
  var year: Int! {
    didSet { self.update() }
  }
  
  @objc func update() {
    DispatchQueue.main.async {
      self._items = Store.shared.transactionItems.items.filter { $0.month == self.month && $0.year == self.year }.sorted{ $0.name < $1.name }
      self.updateFilter()
    }
  }
  
  func fetch() {
    Cloud.fetchTransactionItems(for: self.month, year: self.year) { self.update() }
  }
  
  var items: [TransactionItem] {
    return self.query.isEmpty ? _items : _filteredItems
  }
}

//class FetchTransactionItems: ObservableObject {
//  var month: Int16 {
//    didSet {
//      self.updateRequest()
//    }
//  }
//  var year: Int16 {
//    didSet {
//      self.updateRequest()
//    }
//  }
//
//  @FetchRequest(fetchRequest: TransactionItem.allFetchRequest()) var items: FetchedResults<TransactionItem>
//
//  func updateRequest() {
//    let predicate = NSPredicate(format: "month == %@ AND year == $@", self.month.numberValue, self.year.numberValue)
//    let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
//    _items = FetchRequest(entity: TransactionItem.entity(), sortDescriptors: sortDescriptors, predicate: predicate)
//  }
//
//  init(month: Int16, year: Int16) {
//    self.month = month
//    self.year = year
//    self.updateRequest()
//  }
//
//  func callAsFunction() -> FetchedResults<TransactionItem> {
//    self.items
//  }
//}

