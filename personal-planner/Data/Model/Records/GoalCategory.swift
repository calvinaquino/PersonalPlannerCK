//
//  GoalCategory.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-17.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import CloudKit
import Combine

class GoalCategory: Record, Named {
  override class var recordType: String {
    CKRecord.RecordType.GoalCategory
  }
  
  static func ==(lhs: GoalCategory, rhs: GoalCategory) -> Bool {(
    lhs.id == rhs.id &&
    lhs.name == rhs.name
  )}
  
  override func onSave() {
    Store.shared.goalCategories.save(self)
  }
  
  override func onDelete() {
    Store.shared.goalCategories.delete(self.id)
  }
}

class GoalCategories: ObservableObject, Equatable, Identifiable {
  static let shared = GoalCategories()
  
  let id: String = UUID().uuidString
  
  static func ==(lhs: GoalCategories, rhs: GoalCategories) -> Bool {(
    lhs.id == rhs.id &&
    lhs._items.count == rhs._items.count &&
    lhs._filteredItems.count == rhs._filteredItems.count &&
    lhs.query == rhs.query
  )}
  
  required init() {
    self.itemSubscriber = Store.shared.goalCategories.publisher
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
  @Published private var _items: [GoalCategory] = []
  @Published private var _filteredItems: [GoalCategory] = []
  var query: String = "" {
    didSet {
      self._filteredItems = _items.filter{ self.filterPredicate().evaluate(with: $0.name) }
    }
  }
  
  func filterPredicate() -> NSPredicate {
    NSPredicate(format: "SELF CONTAINS[c] %@", self.query)
  }
  
  func fetch() {
    Cloud.fetchGoalCategories { }
  }
  
  var items: [GoalCategory] {
    return self.query.isEmpty ? _items : _filteredItems
  }
}


