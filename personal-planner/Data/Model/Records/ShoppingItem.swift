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

final class ShoppingItem: NSObject, Record, Named, Priced, Needed {
  var ckRecord: CKRecord!
  var deleted: Bool
  
  required init(with record: CKRecord?) {
    self.deleted = false
    self.ckRecord = record
  }
  
  static func makeRecord(with record: CKRecord) -> ShoppingItem {
    ShoppingItem(with: record)
  }
  
  static func store() -> Cache<ShoppingItem> {
    return Store.shared.shoppingItems
  }
  
  static var recordType: String {
    CKRecord.RecordType.ShoppingItem
  }
  
  var localizedName: String {
    get { self.ckRecord["localizedName"] ?? "" }
    set { self.ckRecord["localizedName"] = newValue }
  }
}

extension ShoppingItem: Categorized {
  typealias ParentCategory = ShoppingCategory
  
  var categoryKey: String { "shoppingCateogory" }
  
  func makeCategory(with record: CKRecord) -> ShoppingCategory {
    ShoppingCategory(with: record)
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
