//
//  ShoppingCategory.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import CloudKit
import Combine

final class ShoppingCategory: NSObject, Record, Named {  
  var ckRecord: CKRecord!
  var deleted: Bool
  
  required init(with record: CKRecord?) {
    self.deleted = false
    self.ckRecord = record
  }
  
  static func makeRecord(with record: CKRecord) -> ShoppingCategory {
    ShoppingCategory(with: record)
  }
  
  static func store() -> Cache<ShoppingCategory> {
    return Store.shared.shoppingCategories
  }
  
  static var recordType: String {
    CKRecord.RecordType.ShoppingCategory
  }
}

class ShoppingCategories: ObservableObject, Equatable, Identifiable {
  static let shared = ShoppingCategories()
  
  let id: String = UUID().uuidString
  
  static func ==(lhs: ShoppingCategories, rhs: ShoppingCategories) -> Bool {(
    lhs.id == rhs.id &&
    lhs._items.count == rhs._items.count &&
    lhs._filteredItems.count == rhs._filteredItems.count &&
    lhs.query == rhs.query
  )}
  
  required init() {
    self.itemSubscriber = Store.shared.shoppingCategories.publisher
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
  @Published private var _items: [ShoppingCategory] = []
  @Published private var _filteredItems: [ShoppingCategory] = []
  var query: String = "" {
    didSet {
      self._filteredItems = _items.filter{ self.filterPredicate().evaluate(with: $0.name) }
    }
  }
  
  func filterPredicate() -> NSPredicate {
    NSPredicate(format: "SELF CONTAINS[c] %@", self.query)
  }
  
  func fetch() {
    Cloud.fetchShoppingCategories { }
  }
  
  var items: [ShoppingCategory] {
    return self.query.isEmpty ? _items : _filteredItems
  }
}
