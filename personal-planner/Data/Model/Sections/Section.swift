//
//  Section.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-31.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import CoreData

protocol Sectionable: Hashable, StringIdentifiable {
  associatedtype Category: StringIdentifiable, Named
  associatedtype Item: Named, Categorized
  typealias FilterItem = (Item) -> Bool
  
  var category: Category? { get set }
  var items: [Item] { get set }
  var categoryName: String { get }
  var generalId: String { get }
  var countVersusTotal: String { get }
  var total: Double { get }
  
  init()
  init(category: Category?, items: [Item])
  static func filter(_ item: Item) -> Bool
  static func sections(items: [Item], categories: [Category], filter: Bool) -> [Self]
}

extension Sectionable where Item : Needed {
  var countVersusTotal: String {
    "\(self.items.filter{!$0.isNeeded}.count)/\(self.items.count)"
  }
}

extension Sectionable where Item : Valued {
  var total: Double {
    self.items.reduce(0) { $1.valueSigned + $0 }
  }
}

extension Sectionable {
//  var generalId: String = UUID().uuidString
  
  init(category: Category?, items: [Item]) {
    self.init()
    self.category = category
    self.items = items
  }
  
  var categoryName: String { category?.name ?? "Geral" }
  var id: String { category?.id ?? "0" }
  var total: Double { 0.0 }
  
  static func filter(_ item: Item) -> Bool {
    true
  }
  
  static func sections(items: [Item], categories: [Category], filter: Bool) -> [Self] {
    var sections: [Self] = []
    let filteredItem = filter ? items.filter(self.filter) : items
    let generalSection = Self(category: nil, items: filteredItem.filter({
      ($0.category == nil)
    }))
    if generalSection.items.count > 0 {
      sections.append(generalSection)
    }
    for category in categories {
      let section = Self(category: category, items: filteredItem.filter({
        ($0.category != nil) ? $0.category!.id == category.id : false
      }))
      if section.items.count > 0 {
        sections.append(section)
      }
    }
    return sections
  }
}

extension Array where Element: Sectionable {

  func hasItem(with name: String) -> Bool {
    for section in self {
      let match = section.items.filter{ $0.name == name }.first != nil
      if match {
        return true
      }
    }
    return false
  }

  var itemCount: Int {
    var total = 0
    for section in self {
      total = total + section.items.count
    }
    return total
  }

  func item(at indexPath: IndexPath) -> Element.Item {
    let section = self[indexPath.section]
    return section.items[indexPath.row]
  }
}

extension Array where Element: Sectionable, Element.Item: Priced {
  var totalTransactions: Double {
    var total = 0.0
    for section in self {
      total = total + section.total
    }
    return total
  }
}
