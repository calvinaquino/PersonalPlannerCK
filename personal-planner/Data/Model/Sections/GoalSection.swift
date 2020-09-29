//
//  GoalSection.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-30.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI
import CoreData

struct GoalSection: Hashable, Identifiable {
  var visible: Bool = true
  var category: GoalCategory?
  var items: [GoalItem]
  
  static let generalId: String = UUID().uuidString;
  
  var categoryName: String {
    category?.name ?? "Geral"
  }
  
  var id: String {
    self.category?.id ?? GoalSection.generalId
  }
  
//  var countVersusTotal: String {
//    "\(self.items.filter{!$0.isNeeded}.count)/\(self.items.count)"
//  }
  
  static func sections(items: [GoalItem], categories: [GoalCategory], filter: Bool) -> [GoalSection] {
    var sections: [GoalSection] = []
    let generalSection = GoalSection(category: nil, items: items.filter({
      ($0.category == nil)
    }))
    if generalSection.items.count > 0 {
      sections.append(generalSection)
    }
    for category in categories {
      let section = GoalSection(category: category, items: items.filter({
        ($0.category != nil) ? $0.category!.id == category.id : false
      }))
      if section.items.count > 0 {
        sections.append(section)
      }
    }
    return sections
  }
}

extension Array where Iterator.Element == GoalSection {
  
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
  
  func item(at indexPath: IndexPath) -> GoalItem {
    let section = self[indexPath.section]
    return section.items[indexPath.row]
  }
}
