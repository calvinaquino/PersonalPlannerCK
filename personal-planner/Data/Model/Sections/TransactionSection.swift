//
//  TransactionSection.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-24.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI
import CoreData

struct TransactionSection: Hashable, Identifiable {
  var category: TransactionCategory?
  var transactions: [TransactionItem]
  
  static let generalId: String = UUID().uuidString;
  
  var categoryName: String {
    category?.name ?? "Geral"
  }
  
  var categoryBudget: Double {
    category?.budget ?? 0.0
  }
  
  var total: Double {
    self.transactions.reduce(0) { ($1.isComplete  ? $1.valueSigned : 0) + $0 }
  }
  
  var id: String {
    self.category?.id ?? TransactionSection.generalId
  }
  
  var currentVersusTotal: String {
    if category == nil {
      return "\(self.total.stringCurrencyValue)"
    }
    return "\((-1 * self.total).stringCurrencyValue)/\(self.categoryBudget.stringCurrencyValue)"
  }
  
  static func sections(items: [TransactionItem], categories: [TransactionCategory]) -> [TransactionSection] {
    var sections: [TransactionSection] = []
    let generalSection = TransactionSection(category: nil, transactions: items.filter({
      ($0.category == nil)
    }))
    if generalSection.transactions.count > 0 {
      sections.append(generalSection)
    }
    for category in categories {
      let section = TransactionSection(category: category, transactions: items.filter({
        ($0.category != nil) ? $0.category!.id == category.id : false
      }))
      if section.transactions.count > 0 {
        sections.append(section)
      }
    }
    return sections
  }
}

extension Array where Iterator.Element == TransactionSection {
  var totalTransactions: Double {
    var total = 0.0
    for section in self {
      total = total + section.total
    }
    return total
  }
  
  var transactionCount: Int {
    var total = 0
    for section in self {
      total = total + section.transactions.count
    }
    return total
  }
  
  func transaction(at indexPath: IndexPath) -> TransactionItem {
    let section = self[indexPath.section]
    return section.transactions[indexPath.row]
  }
}
