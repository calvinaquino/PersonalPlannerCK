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

class PurchaseItem: Record, Named, Priced, Categorized {
  override class var recordType: String {
    CKRecord.RecordType.PurchaseItem
  }
  private let kDescription = "description"
  private let kInstalments = "instalments"
  private let kPurchaseCategory = "purchaseCategory"
  
  static func ==(lhs: PurchaseItem, rhs: PurchaseItem) -> Bool {(
    lhs.id == rhs.id &&
      lhs.name == rhs.name &&
      lhs.price == rhs.price &&
      lhs.description == rhs.description &&
      lhs.instalments == rhs.instalments &&
      lhs.category == rhs.category
    )}
  
  override var description: String {
    get { self.ckRecord[kDescription] ?? "" }
    set { self.ckRecord[kDescription] = newValue }
  }
  var instalments: Int {
    get { self.ckRecord[kInstalments] ?? 0 }
    set { self.ckRecord[kInstalments] = newValue }
  }
  
  var category: PurchaseCategory? {
    get {
      if let reference = self.ckRecord[kPurchaseCategory] as? CKRecord.Reference {
        let record = CKRecord(recordType: PurchaseCategory.recordType, recordID: reference.recordID)
        let cached = Store.shared.purchaseCategories.items.first { $0.id == record.id }
        return cached ?? PurchaseCategory(with: record)
      }
      return nil
    }
    set {
      if let newCategory = newValue {
        let reference = CKRecord.Reference(recordID: newCategory.ckRecord!.recordID, action: .none)
        self.ckRecord[kPurchaseCategory] = reference
      } else {
        self.ckRecord[kPurchaseCategory] = nil
      }
    }
  }
  
  override func onSave() {
    Store.shared.purchaseItems.save(self)
  }
  
  override func onDelete() {
    Store.shared.purchaseItems.delete(self.id)
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
