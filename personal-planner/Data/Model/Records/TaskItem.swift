//
//  TaskItem.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-17.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import CloudKit
import Combine

final class TaskItem: NSObject, Record, Named, Dated {
  var ckRecord: CKRecord!
  var deleted: Bool
  
  required init(with record: CKRecord?) {
    self.deleted = false
    self.ckRecord = record
  }
  
  static func makeRecord(with record: CKRecord) -> TaskItem {
    TaskItem(with: record)
  }
  
  static func store() -> Cache<TaskItem> {
    return Store.shared.taskItems
  }
  
  static var recordType: String {
    CKRecord.RecordType.TaskItem
  }
  
  private let kDescription = "description"
  private let kPriority = "priority"
  private let kRepeatInterval = "repeatInterval"
  private let kRepeats = "repeats"
  
  override var description: String {
    get { self.ckRecord[kDescription] ?? "" }
    set { self.ckRecord[kDescription] = newValue }
  }
  var priority: Int {
    get { self.ckRecord[kPriority] ?? 0 }
    set { self.ckRecord[kPriority] = newValue }
  }
  var repeatInterval: Int {
    get { self.ckRecord[kRepeatInterval] ?? 0 }
    set { self.ckRecord[kRepeatInterval] = newValue }
  }
  var repeats: Bool {
    get { self.ckRecord[kRepeats] ?? false }
    set { self.ckRecord[kRepeats] = newValue }
  }
}

extension TaskItem: Categorized {
  typealias ParentCategory = TaskCategory
  
  var categoryKey: String { "taskCategory" }
  
  func makeCategory(with record: CKRecord) -> TaskCategory {
    TaskCategory(with: record)
  }
}

class TaskItems: ObservableObject {
  static let shared = TaskItems()
  
  required init() {
    self.itemSubscriber = Store.shared.taskItems.publisher
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
  @Published private var _items: [TaskItem] = []
  @Published private var _filteredItems: [TaskItem] = []
  var query: String = "" {
    didSet { self._filteredItems = _items.filter{ self.filterPredicate().evaluate(with: $0.name) } }
  }
  
  func filterPredicate() -> NSPredicate {
    NSPredicate(format: "SELF CONTAINS[c] %@", self.query)
  }
  
  func fetch() {
    Cloud.fetchTaskItems { }
  }
  
  var items: [TaskItem] {
    return self.query.isEmpty ? _items : _filteredItems
  }
}
