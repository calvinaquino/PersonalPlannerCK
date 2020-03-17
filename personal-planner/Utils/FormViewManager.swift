//
//  FormManager.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-16.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import Combine

class FormViewManager {
  static let shared = FormViewManager()
  
  var shoppingItemForm = FormView<ShoppingItem>()
  var shoppingCategoryForm = FormView<ShoppingCategory>()
  var transactionItemForm = FormView<TransactionItem>()
  var transactionCategoryForm = FormView<TransactionCategory>()
}

class FormView<T>: ObservableObject {
  var editingItem: T?
  @Published var isPresented: Bool = false
  
  func show(for item: T?) {
    self.isPresented = true
    self.editingItem = item
  }
  
  func hide() {
    self.isPresented = false
    self.editingItem = nil
  }
}
