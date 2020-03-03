//
//  Store.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import CloudKit

class Store {
  static let shared = Store()
  
  @discardableResult
  func deleteRecord(_ recordID: CKRecord.ID) -> Bool {
    let id = recordID.recordName
    if self.shoppingItems.delete(id) { return true }
    if self.shoppingCategories.delete(id) { return true }
    if self.transactionItems.delete(id) { return true }
    if self.transactionCategories.delete(id) { return true }
    return false
  }
  
  var shoppingItems = Cache<ShoppingItem>(notificationName: .shoppingItem)
  var shoppingCategories = Cache<ShoppingCategory>(notificationName: .shoppingCategory)
  var transactionItems = Cache<TransactionItem>(notificationName: .transactionItem)
  var transactionCategories = Cache<TransactionCategory>(notificationName: .transactionCategory)
}

class Cache<T: Record> {
  init(notificationName: Notification.Name) {
    self.notificationName = notificationName
  }
  
  private var notificationName: Notification.Name
  private var itemCache: [String: T] = [:]
  
  var items: [T] {
    get {
      self.itemCache.map { (key: String, value: T) -> T in
        return value
      }
    }
    set {
      self.itemCache.removeAll()
      newValue.forEach { record in
        self.itemCache[record.id] = record
      }
      NotificationCenter.default.post(name: self.notificationName, object: nil)
    }
  }
  
  func save(_ record: T) {
    self.itemCache[record.id] = record
    NotificationCenter.default.post(name: self.notificationName, object: nil)
  }
  
  @discardableResult
  func delete(_ id: String) -> Bool {
    if self.itemCache[id] != nil {
      self.itemCache[id] = nil
      NotificationCenter.default.post(name: self.notificationName, object: nil)
      return true
    }
    return false
  }
  
  func fetch(_ id: String) -> T? {
    self.itemCache[id]
  }
  
}
