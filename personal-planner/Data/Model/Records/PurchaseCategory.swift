//
//  PurchaseCategory.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-17.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import CloudKit
import Combine

final class PurchaseCategory: NSObject, Record, Named {
  var ckRecord: CKRecord!
  var deleted: Bool
  
  required init(with record: CKRecord?) {
    self.deleted = false
    self.ckRecord = record
  }
  
  static func makeRecord(with record: CKRecord) -> PurchaseCategory {
    PurchaseCategory(with: record)
  }
  
  static func store() -> Cache<PurchaseCategory> {
    return Store.shared.purchaseCategories
  }
  
  static var recordType: String {
    CKRecord.RecordType.PurchaseCategory
  }
}

class PurchaseCategories: ObservableObject, Equatable, Identifiable {
  static let shared = PurchaseCategories()
  
  let id: String = UUID().uuidString
  
  static func ==(lhs: PurchaseCategories, rhs: PurchaseCategories) -> Bool {(
    lhs.id == rhs.id &&
    lhs._items.count == rhs._items.count &&
    lhs._filteredItems.count == rhs._filteredItems.count &&
    lhs.query == rhs.query
  )}
  
  required init() {
    self.itemSubscriber = Store.shared.purchaseCategories.publisher
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
  @Published private var _items: [PurchaseCategory] = []
  @Published private var _filteredItems: [PurchaseCategory] = []
  var query: String = "" {
    didSet {
      self._filteredItems = _items.filter{ self.filterPredicate().evaluate(with: $0.name) }
    }
  }
  
  func filterPredicate() -> NSPredicate {
    NSPredicate(format: "SELF CONTAINS[c] %@", self.query)
  }
  
  func fetch() {
    Cloud.fetchPurchaseCategories { }
  }
  
  var items: [PurchaseCategory] {
    return self.query.isEmpty ? _items : _filteredItems
  }
}


