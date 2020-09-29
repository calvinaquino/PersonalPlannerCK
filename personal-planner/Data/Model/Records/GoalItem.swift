//
//  GoalItem.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-17.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import CloudKit
import Combine

class GoalItem: Record, Named, Priced, Categorized, FormCategoryPickerMenu {
  override class var recordType: String {
    CKRecord.RecordType.GoalItem
  }
  private let kDescription = "description"
  private let kInstalments = "instalments"
  private let kGoalCategory = "goalCategory"
  
  static func ==(lhs: GoalItem, rhs: GoalItem) -> Bool {(
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
  
  var category: GoalCategory? {
    get {
      if let reference = self.ckRecord[kGoalCategory] as? CKRecord.Reference {
        let record = CKRecord(recordType: GoalCategory.recordType, recordID: reference.recordID)
        let cached = Store.shared.goalCategories.items.first { $0.id == record.id }
        return cached ?? GoalCategory(with: record)
      }
      return nil
    }
    set {
      if let newCategory = newValue {
        let reference = CKRecord.Reference(recordID: newCategory.ckRecord!.recordID, action: .none)
        self.ckRecord[kGoalCategory] = reference
      } else {
        self.ckRecord[kGoalCategory] = nil
      }
    }
  }
  
  override func onSave() {
    Store.shared.goalItems.save(self)
  }
  
  override func onDelete() {
    Store.shared.goalItems.delete(self.id)
  }
  
  // this is repeated
  var selectedCategoryName: String {
    if let category = self.category {
      return category.name
    }
    return "Geral"
  }
}

class GoalItems: ObservableObject {
  static let shared = GoalItems()
  
  required init() {
    self.itemSubscriber = Store.shared.goalItems.publisher
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
  @Published private var _items: [GoalItem] = []
  @Published private var _filteredItems: [GoalItem] = []
  var query: String = "" {
    didSet { self._filteredItems = _items.filter{ self.filterPredicate().evaluate(with: $0.name) } }
  }
  
  func filterPredicate() -> NSPredicate {
    NSPredicate(format: "SELF CONTAINS[c] %@", self.query)
  }
  
  func fetch() {
    Cloud.fetchGoalItems { }
  }
  
  var items: [GoalItem] {
    return self.query.isEmpty ? _items : _filteredItems
  }
}
