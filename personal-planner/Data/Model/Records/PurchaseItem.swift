//
//  PurchaseItem.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-17.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import CloudKit
import Combine

final class PurchaseItem: NSObject, Record, Named, Priced {
  var ckRecord: CKRecord!
  var deleted: Bool
  
  required init(with record: CKRecord?) {
    self.deleted = false
    self.ckRecord = record
  }
  
  static func makeRecord(with record: CKRecord) -> PurchaseItem {
    PurchaseItem(with: record)
  }
  
  static func store() -> Cache<PurchaseItem> {
    return Store.shared.purchaseItems
  }
  
  static var recordType: String {
    CKRecord.RecordType.PurchaseItem
  }
  private let kDescription = "description"
  private let kInstalments = "instalments"
  
  override var description: String {
    get { self.ckRecord[kDescription] ?? "" }
    set { self.ckRecord[kDescription] = newValue }
  }
  var instalments: Int {
    get { self.ckRecord[kInstalments] ?? 0 }
    set { self.ckRecord[kInstalments] = newValue }
  }
}

extension PurchaseItem: Categorized {
  typealias ParentCategory = PurchaseCategory
  
  var categoryKey: String { "purchaseCategory" }
  
  func makeCategory(with record: CKRecord) -> PurchaseCategory {
    PurchaseCategory(with: record)
  }
}

class PurchaseItems: ObservableObject {
  static let shared = PurchaseItems()
  
  required init() {
    self.itemSubscriber = Store.shared.purchaseItems.publisher
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
  @Published private var _items: [PurchaseItem] = []
  @Published private var _filteredItems: [PurchaseItem] = []
  var query: String = "" {
    didSet { self._filteredItems = _items.filter{ self.filterPredicate().evaluate(with: $0.name) } }
  }
  
  func filterPredicate() -> NSPredicate {
    NSPredicate(format: "SELF CONTAINS[c] %@", self.query)
  }
  
  func fetch() {
    Cloud.fetchPurchaseItems { }
  }
  
  var items: [PurchaseItem] {
    return self.query.isEmpty ? _items : _filteredItems
  }
}
