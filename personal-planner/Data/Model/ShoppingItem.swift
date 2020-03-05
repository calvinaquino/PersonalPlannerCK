//
//  ShoppingItem.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI
import CloudKit
import Combine

class ShoppingItem : Record {
  override class var recordType: String {
    "ShoppingItem"
  }
  
  static func ==(lhs: ShoppingItem, rhs: ShoppingItem) -> Bool {(
    lhs.id == rhs.id &&
    lhs.name == rhs.name &&
    lhs.localizedName == rhs.localizedName &&
    lhs.isNeeded == rhs.isNeeded &&
    lhs.shoppingCategory == rhs.shoppingCategory
  )}
  
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
  static let shared = ShoppingItems()
  
  required init() {
    self.itemSubscriber = Store.shared.shoppingItems.publisher
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
  @Published private var _items: [ShoppingItem] = []
  @Published private var _filteredItems: [ShoppingItem] = []
  var query: String = "" {
    didSet { self._filteredItems = _items.filter{ self.filterPredicate().evaluate(with: $0.name) } }
  }
  
  func filterPredicate() -> NSPredicate {
    NSPredicate(format: "SELF CONTAINS[c] %@", self.query)
  }
  
  func fetch() {
    Cloud.fetchShoppingItems { }
  }
  
  var items: [ShoppingItem] {
    return self.query.isEmpty ? _items : _filteredItems
  }
}
