//
//  TransactionCategory.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import CloudKit

class TransactionCategory: Record {
  override class var recordType: String {
    "TransactionCategory"
  }
  
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
  required init() {
    self.update()
  NotificationCenter.default.addObserver(self, selector: #selector(update), name: .transactionCategory, object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  @Published private var _items: [TransactionCategory] = Store.shared.transactionCategories.items
  @Published private var _filteredItems: [TransactionCategory] = []
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
  
  @objc func update() {
    DispatchQueue.main.async {
      self._items = Store.shared.transactionCategories.items
      self.updateFilter()
    }
  }
  
  func fetch() {
    Cloud.fetchTransactionCategories { self.update() }
  }
  
  var items: [TransactionCategory] {
    return self.query.isEmpty ? _items : _filteredItems
  }
}
