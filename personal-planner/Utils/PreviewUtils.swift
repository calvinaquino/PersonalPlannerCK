//
//  PreviewUtils.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-09-22.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import SwiftUI

/// Mock Data

class Mock {
  static func mockTransactions() {
    let mockedCategories: [TransactionCategory] = {
      let cat = TransactionCategory()
      cat.name = "Category"
      cat.budget = 100.00
      return [cat]
    }()
    
    let mockedIems: [TransactionItem] = {
      let item1: TransactionItem = {
        let item = TransactionItem()
        item.name = "Item1"
        item.value = 50.00
        item.isComplete = true
        item.category = mockedCategories.first
        return item
      }()
      
      let item2: TransactionItem = {
        let item = TransactionItem()
        item.name = "Item2"
        item.value = 75.00
        item.isInflow = true
        item.isComplete = true
        item.category = mockedCategories.first
        return item
      }()
      
      let item3: TransactionItem = {
        let item = TransactionItem()
        item.name = "Item3"
        item.value = 25.00
        item.isComplete = false
        item.category = mockedCategories.first
        return item
      }()
      return [item1, item2, item3]
    }()
    
    Store.shared.transactionCategories.items = mockedCategories
    Store.shared.transactionItems.items = mockedIems
  }
}
