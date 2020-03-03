//
//  ShoppingCategory.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import CloudKit

class ShoppingCategory: Record {
  override class var recordType: String {
    "ShoppingCategory"
  }
  
  var name: String {
    get { self.ckRecord["name"] ?? "" }
    set { self.ckRecord["name"] = newValue }
  }
  
  override var debugDescription: String {
    "Category - name: \(name)"
  }
  
  override func onSave() {
    Store.shared.shoppingCategories.save(self)
  }
  
  override func onDelete() {
    Store.shared.shoppingCategories.delete(self.id)
  }
}

class ShoppingCategories: ObservableObject {
  required init() {
    self.fetch()
    NotificationCenter.default.addObserver(self, selector: #selector(update), name: .shoppingCategory, object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  @Published private var _items: [ShoppingCategory] = Store.shared.shoppingCategories.items
  @Published private var _filteredItems: [ShoppingCategory] = []
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
      self._items = Store.shared.shoppingCategories.items
      self.updateFilter()
    }
  }
  
  func fetch() {
    Cloud.fetchShoppingCategories { self.update() }
  }
  
  var items: [ShoppingCategory] {
    return self.query.isEmpty ? _items : _filteredItems
  }
}
