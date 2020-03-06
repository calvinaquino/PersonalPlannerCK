//
//  Store.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI
import CloudKit
import Combine

class Store {
  init() {
    Cloud.fetchShoppingCategories { }
    Cloud.fetchTransactionCategories { }
    Cloud.fetchShoppingItems { }
    Cloud.fetchTransactionItems(for: Date()) { }
  }
  
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
  
  var shoppingItems = Cache<ShoppingItem>()
  var shoppingCategories = Cache<ShoppingCategory>()
  var transactionItems = Cache<TransactionItem>()
  var transactionCategories = Cache<TransactionCategory>()
}

class Cache<T: Record> {
  init() {
    self.subject = CurrentValueSubject<[T], Never>([])
    self.publisher = self.subject.eraseToAnyPublisher()
  }
  
  let subject: CurrentValueSubject<[T], Never>
  let publisher: AnyPublisher<[T], Never>
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
      self.subject.send(self.items)
    }
  }
  
  func save(_ record: T) {
    self.itemCache[record.id] = record
    self.subject.send(self.items)
  }
  
  @discardableResult
  func delete(_ id: String) -> Bool {
    if self.itemCache[id] != nil {
      self.itemCache[id] = nil
      self.subject.send(self.items)
      return true
    }
    return false
  }
  
  func fetch(_ id: String) -> T? {
    self.itemCache[id]
  }
  
}
