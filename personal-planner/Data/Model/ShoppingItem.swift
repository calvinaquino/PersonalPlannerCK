//
//  ShoppingItem.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI
import CloudKit

class ShoppingItem : Record {
  override class var recordType: String {
    "ShoppingItem"
  }
  
  var name: String {
    get { self.ckRecord["name"] ?? "" }
    set { self.ckRecord["name"] = newValue }
  }
  var localizedName: String {
    get { self.ckRecord["localizedName"] ?? "" }
    set { self.ckRecord["localizedName"] = newValue }
  }
  var price: Double {
    get { self.ckRecord["price"] ?? 0.0 }
    set { self.ckRecord["price"] = newValue }
  }
  var isNeeded: Bool {
    get { self.ckRecord["isNeeded"] ?? false }
    set { self.ckRecord["isNeeded"] = newValue }
  }
  
  var shoppingCategory: ShoppingCategory? {
    get {
      if let reference = self.ckRecord["shoppingCategory"] as? CKRecord.Reference {
        let record = CKRecord(recordType: ShoppingCategory.recordType, recordID: reference.recordID)
        let cached = Store.shared.shoppingCategories.items.first { $0.id == record.id }
        return cached ?? ShoppingCategory(with: record)
      }
      return nil
    }
    set {
      if let newShoppingCategory = newValue {
        let reference = CKRecord.Reference(recordID: newShoppingCategory.ckRecord!.recordID, action: .none)
        self.ckRecord["shoppingCategory"] = reference
      } else {
        self.ckRecord["shoppingCategory"] = nil
      }
    }
  }
  
  override var debugDescription: String {
    "Item - name: \(name), price: \(price)"
  }
  
  override func onSave() {
    Store.shared.shoppingItems.save(self)
  }
  
  override func onDelete() {
    Store.shared.shoppingItems.delete(self.id)
  }
}

class ShoppingItems: ObservableObject {
  required init() {
    self.fetch()
    NotificationCenter.default.addObserver(self, selector: #selector(update), name: .shoppingItem, object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  
  @Published private var _items: [ShoppingItem] = []
  @Published private var _filteredItems: [ShoppingItem] = []
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
      self._items = Store.shared.shoppingItems.items.sorted{ $0.name < $1.name }
      self.updateFilter()
    }
  }
  
  func fetch() {
    Cloud.fetchShoppingItems { self.update() }
  }
  
  var items: [ShoppingItem] {
    return self.query.isEmpty ? _items : _filteredItems
  }
}
