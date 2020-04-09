//
//  TaskCategory.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-17.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import CloudKit
import Combine

class TaskCategory: Record, Named {
  override class var recordType: String {
    CKRecord.RecordType.TaskCategory
  }
  static func ==(lhs: TaskCategory, rhs: TaskCategory) -> Bool {(
    lhs.id == rhs.id &&
    lhs.name == rhs.name
  )}
  
  private let kName = "name"
  
  var name: String {
    get { self.ckRecord[kName] ?? "" }
    set { self.ckRecord[kName] = newValue }
  }
  
  override func onSave() {
    Store.shared.taskCategories.save(self)
  }
  
  override func onDelete() {
    Store.shared.taskCategories.delete(self.id)
  }
}

class TaskCategories: ObservableObject, Equatable, Identifiable {
  static let shared = TaskCategories()
  
  let id: String = UUID().uuidString
  
  static func ==(lhs: TaskCategories, rhs: TaskCategories) -> Bool {(
    lhs.id == rhs.id &&
    lhs._items.count == rhs._items.count &&
    lhs._filteredItems.count == rhs._filteredItems.count &&
    lhs.query == rhs.query
  )}
  
  required init() {
    self.itemSubscriber = Store.shared.taskCategories.publisher
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
  @Published private var _items: [TaskCategory] = []
  @Published private var _filteredItems: [TaskCategory] = []
  var query: String = "" {
    didSet {
      self._filteredItems = _items.filter{ self.filterPredicate().evaluate(with: $0.name) }
    }
  }
  
  func filterPredicate() -> NSPredicate {
    NSPredicate(format: "SELF CONTAINS[c] %@", self.query)
  }
  
  func fetch() {
    Cloud.fetchTaskCategories { }
  }
  
  var items: [TaskCategory] {
    return self.query.isEmpty ? _items : _filteredItems
  }
}

