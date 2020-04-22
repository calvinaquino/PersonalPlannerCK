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

class TaskItem: Record, Named, Categorized {
  override class var recordType: String {
    CKRecord.RecordType.TaskItem
  }
  
  private let kDate = "date"
  private let kDescription = "description"
  private let kName = "name"
  private let kPriority = "priority"
  private let kRepeatInterval = "repeatInterval"
  private let kRepeats = "repeats"
  private let kTaskCategory = "taskCategory"
  
  static func ==(lhs: TaskItem, rhs: TaskItem) -> Bool {(
    lhs.id == rhs.id &&
    lhs.name == rhs.name &&
    lhs.date == rhs.date &&
    lhs.description == rhs.description &&
    lhs.priority == rhs.priority &&
    lhs.repeats == rhs.repeats &&
    lhs.category == rhs.category
  )}
  
  var date: Date {
    get { self.ckRecord[kDate] ?? Date() }
    set { self.ckRecord[kDate] = newValue }
  }
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
  
  var category: TaskCategory? {
    get {
      if let reference = self.ckRecord[kTaskCategory] as? CKRecord.Reference {
        let record = CKRecord(recordType: TaskCategory.recordType, recordID: reference.recordID)
        let cached = Store.shared.taskCategories.items.first { $0.id == record.id }
        return cached ?? TaskCategory(with: record)
      }
      return nil
    }
    set {
      if let newShoppingCategory = newValue {
        let reference = CKRecord.Reference(recordID: newShoppingCategory.ckRecord!.recordID, action: .none)
        self.ckRecord[kTaskCategory] = reference
      } else {
        self.ckRecord[kTaskCategory] = nil
      }
    }
  }
  
  override func onSave() {
    Store.shared.taskItems.save(self)
  }
  
  override func onDelete() {
    Store.shared.taskItems.delete(self.id)
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
