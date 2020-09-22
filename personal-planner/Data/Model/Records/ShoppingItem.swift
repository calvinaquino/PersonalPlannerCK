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

class ShoppingItem : Record, Named, Priced, Needed, Categorized, FormCategoryPickerMenu {
  override class var recordType: String {
    CKRecord.RecordType.ShoppingItem
  }
  
  private let kLocalizedName = "localizedName"
  private let kShoppingCategory = "shoppingCateogory"
  
  static func ==(lhs: ShoppingItem, rhs: ShoppingItem) -> Bool {(
    lhs.id == rhs.id &&
    lhs.name == rhs.name &&
    lhs.localizedName == rhs.localizedName &&
    lhs.isNeeded == rhs.isNeeded &&
    lhs.category == rhs.category
  )}
  
  var localizedName: String {
    get { self.ckRecord[kLocalizedName] ?? "" }
    set { self.ckRecord[kLocalizedName] = newValue }
  }
  
  var category: ShoppingCategory? {
    get {
      if let reference = self.ckRecord[kShoppingCategory] as? CKRecord.Reference {
        let record = CKRecord(recordType: ShoppingCategory.recordType, recordID: reference.recordID)
        let cached = Store.shared.shoppingCategories.items.first { $0.id == record.id }
        return cached ?? ShoppingCategory(with: record)
      }
      return nil
    }
    set {
      if let newShoppingCategory = newValue {
        let reference = CKRecord.Reference(recordID: newShoppingCategory.ckRecord!.recordID, action: .none)
        self.ckRecord[kShoppingCategory] = reference
      } else {
        self.ckRecord[kShoppingCategory] = nil
      }
    }
  }
  
  override func onSave() {
    Store.shared.shoppingItems.save(self)
  }
  
  override func onDelete() {
    Store.shared.shoppingItems.delete(self.id)
  }
  
  var selectedCategoryName: String {
    if let category = self.category {
      return category.name
    }
    return "Geral"
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
